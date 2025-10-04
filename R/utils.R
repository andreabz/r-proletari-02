# R/utils.R
# Funzioni generali utilizzate in varie parti del progetto
library(data.table)

#' Pulizia e normalizzazione dati ARPAE
#'
#' Pulisce e converte i dati scaricati dall'API ARPAE:
#' - rimuove colonne inutili,
#' - normalizza i nomi delle colonne,
#' - converte `reftime` in `POSIXct`,
#' - trasforma le colonne numeriche in numeric,
#' - lascia `v_flag` come carattere.
#'
#' @param dt Oggetto `data.table` con i dati scaricati da ARPAE.
#'
#' @return Un `data.table` con colonne normalizzate e convertite.
#' @examples
#' \dontrun{
#' raw <- data.table::data.table(
#'   reftime = "08/21/2025 02:00", value = "15", v_flag = "G"
#' )
#' pulisci_dati(raw)
#' }
pulisci_dati <- function(dt) {
  
  # rimuove la colonna _full_text se presente
  if ("_full_text" %in% names(dt)) dt[, `_full_text` := NULL]
  
  # normalizza nomi colonne
  clean_names <- tolower(gsub("[^a-zA-Z0-9]", "_", names(dt)))
  
  # evita che inizino con underscore
  clean_names <- ifelse(substr(clean_names, 1, 1) == "_", gsub("_", "", clean_names), clean_names)
  
  setnames(dt, clean_names)
  
  # converte reftime in POSIXct
  if ("reftime" %in% names(dt)) {
    dt[, reftime := as.POSIXct(reftime, format = "%m/%d/%Y %H:%M", tz = "UTC")]
  }
  
  # colonne da convertire in numerico
  num_cols <- intersect(c("id", "station_id", "variable_id", "value"), names(dt))
  for (col in num_cols) {
    dt[[col]] <- as.numeric(dt[[col]])
  }
  
  # v_flag rimane character
  if ("v_flag" %in% names(dt)) dt[, v_flag := as.character(v_flag)]
  
  dt
}