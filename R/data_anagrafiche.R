#' Carica e prepara le anagrafiche delle stazioni
#'
#' Questa funzione scarica (se necessario), carica e pulisce le tabelle
#' di anagrafica delle stazioni di qualità dell'aria.
#' Inoltre filtra l'elenco delle stazioni corrispondenti a una determinata
#' provincia, identificata dalla sua sigla.
#'
#' @param prov_sigla Sigla della provincia di interesse (es. `"RE"` per Reggio Emilia).
#'   Il valore di default è `"RE"`.
#'
#' @return Una lista con due oggetti:
#' \itemize{
#'   \item \code{stazioni_selezionate}: vettore dei codici stazione della provincia scelta.
#'   \item \code{anagrafica_stazioni}: tabella con le informazioni sulle stazioni, pulita e formattata.
#' }
#'
#' @details
#' La funzione esegue i seguenti passaggi:
#' \enumerate{
#'   \item Controlla la presenza del file CSV di anagrafica (\code{anagrafica_stazioni.csv}
#'         nella cartella \code{data/}.
#'   \item Se i file non sono presenti, li scarica da fonti pubbliche predefinite.
#'   \item Carica le tabelle, ripulisce i nomi delle variabili con \code{pulisci_dati()} e
#'         sostituisce eventuali simboli o unità di misura non formattati.
#'   \item Restituisce sia le anagrafiche complete sia l'elenco delle stazioni della
#'         provincia selezionata.
#' }
#'
#' @examples
#' \dontrun{
#'   # Carico le anagrafiche per la provincia di Reggio Emilia
#'   anagrafiche <- carica_anagrafiche("RE")
#'
#'   # Estraggo le stazioni selezionate
#'   anagrafiche$stazioni_selezionate
#' }
#'
#' @seealso \code{\link{scarica_dati_sql}}, \code{\link{pulisci_dati}}
#'
#' @export
carica_anagrafiche <- function(prov_sigla = "RE") {
  
  # Scarico i file solo se mancano
  if (!file.exists("data/anagrafica_stazioni.csv")) {
    download.file(
      url = "https://docs.google.com/spreadsheets/d/1-4wgZ8JeLeg0bODTSFUrshPY-_y9mERUu0FJtSFr78s/export?format=csv",
      destfile = "data/anagrafica_stazioni.csv"
    )
  }
  
  # Carico e pulisco
  anagrafica_stazioni <- fread("data/anagrafica_stazioni.csv") |> pulisci_dati()
  anagrafica_stazioni[, cod_staz := as.numeric(gsub("\\.", "", cod_staz))]
  anagrafica_stazioni[, um := gsub("ug/m3", "µg/m³", um)]
  
  # Filtra le stazioni della provincia scelta
  stazioni_selezionate <- anagrafica_stazioni[provincia == prov_sigla, unique(cod_staz)]
  
  # Ritorno sia le anagrafiche che l’elenco delle stazioni
  list(
    stazioni_selezionate = stazioni_selezionate,
    anagrafica_stazioni = anagrafica_stazioni
  )
}