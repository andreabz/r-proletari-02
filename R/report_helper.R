# report_helper.R
# Funzioni di supporto per generazione report giornaliero qualità dell'aria
# Contiene funzioni per commentare automaticamente i superamenti e generare sezioni di report
library(data.table)
library(ggplot2)
library(gt)

#' Commento automatico dei superamenti per un parametro
#'
#' Genera un commento in stile militante sovietico sui superamenti dei limiti normativi
#' dei principali parametri atmosferici.
#'
#' @param dati_param data.table con i risultati di report_giornaliero() per un parametro
#' @param parametro stringa: "PM10", "PM2.5", "NO2", "O3", "SO2", "CO"
#' @return stringa con commento sovietico, coerente con la normativa
commento_superamenti <- function(dati_param, parametro) {
  
  if (nrow(dati_param) == 0) {
    return(paste0("Compagni, purtroppo non ci sono dati per il parametro ", parametro, 
                  ". Il nemico borghese ci ha privato delle informazioni!"))
  }
  
  commenti <- c()
  
  # Associazione colonne superamento → descrizione normativa
  desc_super <- switch(parametro,
                       "PM10" = list(supera_50 = "limite giornaliero 50 µg/m³"),
                       "PM2.5" = list(),  # non ci sono limiti calcolati
                       "NO2" = list(n_supera_200 = "limite orario 200 µg/m³",
                                    n_supera_400_3h = "limite 3h consecutive 400 µg/m³"),
                       "O3" = list(n_supera_120 = "media mobile 8h 120 µg/m³",
                                   n_supera_180_orario = "limite orario 180 µg/m³",
                                   n_supera_240_3h = "limite 3h consecutive 240 µg/m³"),
                       "SO2" = list(),  # vuoto
                       "CO" = list(n_supera_10 = "massimo della media mobile di 8 ore 10 mg/m³"),
                       list())
  
  if(length(desc_super) == 0) {
    return(paste0("Per il parametro ", parametro, " non sono stati calcolati superamenti."))
  }
  
  # Ciclo sulle colonne di superamento
  for(col in names(desc_super)) {
    if(!(col %in% names(dati_param))) next
    
    n_super <- sum(dati_param[[col]], na.rm = TRUE)
    stazioni_super <- unique(dati_param[dati_param[[col]] > 0, stazione])
    
    descr <- desc_super[[col]]
    
    if(n_super == 0) {
      commenti <- c(commenti, paste0("Per il parametro ", parametro, 
                                     " non si registrano superamenti del ", descr, 
                                     " presso le stazioni considerate."))
    } else {
      plurale <- ifelse(n_super == 1, "", "i")
      commenti <- c(commenti, paste0("Per il parametro ", parametro, 
                                     " si registra", plurale, " ", n_super, 
                                     " superamento", plurale, " del ", descr, 
                                     " presso la(e) stazione(i) ", 
                                     paste(stazioni_super, collapse = ", "), "."))
    }
  }
  
  paste(commenti, collapse = "\n")
}

#' Genera una sezione completa del report per un parametro
#'
#' Stampa testo introduttivo militante, tabella dei valori calcolati e grafico, 
#' aggiungendo il commento sui superamenti
#'
#' @param dati data.table con i dati orari del giorno
#' @param parametro stringa: "PM10", "PM2.5", "NO2", "O3", "SO2", "CO"
#' @param limiti lista dei limiti per ciascun parametro, es. list("PM10"=50,"NO2"=200)
#' @param testo_intro testo opzionale introduttivo militante
#' @return NULL, stampa direttamente la sezione del report
sezione_parametro <- function(dati, parametro, limiti, testo_intro = NULL) {
  
  if (is.null(testo_intro)) {
    testo_intro <- paste0("Compagni, il glorioso popolo lavoratore deve essere informato sui valori del parametro ", parametro, ".")
  }
  
  cat("## ", parametro, "\n\n")
  cat(testo_intro, "\n\n")
  
  # Prelevo i dati relativi al parametro dal dataset giornaliero
  dati_param <- switch(parametro,
                       "PM10" = dati$PM10,
                       "PM2.5" = dati$PM2.5,
                       "NO2" = dati$NO2,
                       "O3" = dati$O3,
                       "SO2" = dati$SO2,
                       "CO" = dati$CO,
                       NULL)
  
  if(is.null(dati_param) || nrow(dati_param) == 0) {
    cat(paste0("Compagni, purtroppo non ci sono dati per il parametro ", parametro, 
               ". Il nemico borghese ci ha privato delle informazioni!\n\n"))
    return(NULL)
  }
  
  # Stampa tabella con gt()
  tab <- dati_param %>% gt()
  print(tab)
  cat("\n\n")
  
  # Grafico per parametri orari
  if(parametro %in% c("O3","NO2","SO2","CO")) {
    graf <- grafico_parametro(dati_param, parametro)
    print(graf)
    cat("\n\n")
  }
  
  # Commento automatico dei superamenti
  if(parametro %in% names(limiti)) {
    commento <- commento_superamenti(dati_param, parametro)
    cat(commento, "\n\n")
  }
}

#' Genera tutte le sezioni del report per i parametri presenti
#'
#' @param dati lista di data.table restituita da report_giornaliero()
#' @param limiti lista dei limiti per ciascun parametro
#' @return NULL, stampa direttamente tutte le sezioni
report_giornaliero_sezioni <- function(dati, limiti) {
  parametri <- names(dati)
  for(param in parametri) {
    sezione_parametro(dati, param, limiti)
  }
}
