#' Grafico orario per O3 con facet per stazione
#'
#' @param dati data.table con dati orari
#' @details Grafico con ore del giorno sull'asse X, concentrazione O3 (µg/m³) sull'asse Y,
#'          punti e linea per le concentrazioni orarie, linea orizzontale per limite orario 180 µg/m³,
#'          facet per stazione (una colonna, tante righe quante le stazioni).
grafico_o3 <- function(dati) {
  okabe_ito <- c("O3" = "#56B4E9")
  limite_color <- "#D55E00"
  
  x <- dati[parametro == "O3 (Ozono)"]
  nome_stazione <- unique(x$stazione)
  lim_orario <- 180
  
  ggplot(x, aes(x = reftime, y = value)) +
    geom_point(color = okabe_ito["O3"]) +
    geom_line(aes(group = 1), color = okabe_ito["O3"], alpha = 0.4) +
    geom_hline(yintercept = lim_orario, linetype = "dashed", color = limite_color) +
    scale_x_datetime(date_labels = "%H:%M", name = "Ora del giorno") +
    labs(
      y = expression("Concentrazione O"[3]*" (µg/m³)"),
    ) +
    facet_wrap(~ stazione, ncol = 1, scales = "free_y") +
    theme_bw()
}

#' Grafico orario per NO2 con facet per stazione
#'
#' @param dati data.table con dati orari
#' @details Grafico con ore del giorno sull'asse X, concentrazione NO2 (µg/m³) sull'asse Y,
#'          punti e linea per le concentrazioni orarie, linea orizzontale per limite orario 200 µg/m³,
#'          facet per stazione (una colonna, tante righe quante le stazioni).
grafico_no2 <- function(dati) {
  okabe_ito <- c("NO2" = "#009E73")
  limite_color <- "#D55E00"
  
  x <- dati[parametro == "NO2 (Biossido di azoto)"]
  nome_stazione <- unique(x$stazione)
  lim_orario <- 200
  
  ggplot(x, aes(x = reftime, y = value)) +
    geom_point(color = okabe_ito["NO2"]) +
    geom_line(aes(group = 1), color = okabe_ito["NO2"], alpha = 0.4) +
    geom_hline(yintercept = lim_orario, linetype = "dashed", color = limite_color) +
    scale_x_datetime(date_labels = "%H:%M", name = "Ora del giorno") +
    labs(
      y = expression("Concentrazione NO"[2]*" (µg/m³)"),
    ) +
    facet_wrap(~ stazione, ncol = 1, scales = "free_y") +
    theme_bw()
}

#' Grafico orario per SO2 con facet per stazione
#'
#' @param dati data.table con dati orari
#' @details Grafico con ore del giorno sull'asse X, concentrazione SO2 (µg/m³) sull'asse Y,
#'          punti e linea per le concentrazioni orarie, linea orizzontale per limite orario 350 µg/m³,
#'          facet per stazione (una colonna, tante righe quante le stazioni).
grafico_so2 <- function(dati) {
  okabe_ito <- c("SO2" = "#CC79A7")
  limite_color <- "#D55E00"
  
  x <- dati[parametro == "SO2 (Biossido di zolfo)"]
  nome_stazione <- unique(x$stazione)
  lim_orario <- 350
  
  ggplot(x, aes(x = reftime, y = value)) +
    geom_point(color = okabe_ito["SO2"]) +
    geom_line(aes(group = 1), color = okabe_ito["SO2"], alpha = 0.4) +
    geom_hline(yintercept = lim_orario, linetype = "dashed", color = limite_color) +
    scale_x_datetime(date_labels = "%H:%M", name = "Ora del giorno") +
    labs(
      y = expression("Concentrazione SO"[2]*" (µg/m³)"),
    ) +
    facet_wrap(~ stazione, ncol = 1, scales = "free_y") +
    theme_bw()
}

#' Wrapper grafico per i principali parametri con facet per stazione
#'
#' @param dati data.table con dati orari
#' @param parametro stringa: "O3", "NO2", "SO2"
#' @details Restituisce il grafico ggplot del parametro scelto per tutte le stazioni presenti nel dataset,
#'          usando punti e linea, limite orario con annotazione e facet per stazione (una colonna).
grafico_parametro <- function(dati, parametro) {
  if (parametro == "O3") {
    grafico_o3(dati)
  } else if (parametro == "NO2") {
    grafico_no2(dati)
  } else if (parametro == "SO2") {
    grafico_so2(dati)
  } else {
    stop("Parametro non supportato per la visualizzazione grafica")
  }
}
