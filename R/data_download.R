# R/download_dati.R
# Scarica dati ARPAE Emilia-Romagna via SQL API, prepara per elaborazione e log
# Dipendenze minime: httr2, data.table

#' Sanitize SQL input
#'
#' Rimuove tutti i caratteri non ammessi da una stringa per prevenire
#' rischi di SQL injection. Mantiene solo lettere, numeri, underscore,
#' spazio e slash.
#'
#' @param x Character vector da sanitizzare.
#'
#' @return Character vector ripulito.
#' @examples
#' sanitize_sql("DROP TABLE utenti; --")
#' # [1] "DROP TABLE utenti "
sanitize_sql <- function(x) {
  gsub("[^a-zA-Z0-9_ /]", "", x)
}

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

#' Scarica dati ARPAE con query SQL
#'
#' Interroga l'API CKAN di ARPAE con una query SQL parametrizzata,
#' filtrando per `station_id` e per data specifica (`reftime`).
#' La data viene passata dall'utente in formato `dd/mm/YYYY` e
#' convertita automaticamente nel formato `MM/DD/YYYY` richiesto
#' dal dataset.
#'
#' @param dataset_id Stringa, identificativo del dataset su ARPAE.
#' @param stazioni_selezionate Vettore di character, codici stazione da includere.
#' @param data_selezionata Stringa, data in formato `dd/mm/YYYY`.
#' @param limit Intero, numero massimo di record da scaricare (default: 1000).
#' @param offset Intero, offset per la paginazione (default: 0).
#'
#' @return Un `data.table` con i dati filtrati e puliti. Se non ci sono
#' record disponibili, restituisce un `data.table` vuoto.
#'
#' @examples
#' \dontrun{
#' dati <- scarica_dati_sql(
#'   dataset_id = "4dc855a1-6298-4b71-a1ae-d80693d43dcb",
#'   stazioni_selezionate = c("3000001", "3000022"),
#'   data_selezionata = "21/08/2025"
#' )
#' }
scarica_dati_sql <- function(dataset_id,
                             stazioni_selezionate,
                             data_selezionata,
                             limit = 1000,
                             offset = 0) {
  
  # ripulisco i valori di input e li trasformo in formati utili per SQL
  stations_sql <- paste0("('", paste(stazioni_selezionate |> sanitize_sql(), collapse = "','"), "')")
  data_sql <- format(as.Date(data_selezionata |> sanitize_sql(), "%d/%m/%Y"), "%m/%d/%Y")
  
  # costruisco la query parametrizzata
  sql <- sprintf("
  SELECT *
  FROM \"%s\"
  WHERE station_id IN %s
    AND reftime LIKE '%s%%'
  LIMIT %d OFFSET %d
", dataset_id, stations_sql, data_sql, limit, offset)
  
  url <- "https://dati.arpae.it/api/3/action/datastore_search_sql"
  
  # costruisco la richiesta all'API
  req <- request(url) |>
    req_method("POST") |>
    req_body_json(list(sql = sql))
  
  # salvo il risultato
  resp <- req_perform(req)
  content_json <- resp_body_json(resp, simplifyVector = TRUE)
  
  # se ottengo qualcosa, gli do una pulita e lo converto in data.table
  if (!is.null(nrow(content_json$result$records))) {
    dt <- as.data.table(content_json$result$records)
    dt <- pulisci_dati(dt)
    dt
  } else {
    data.table()
  }
}