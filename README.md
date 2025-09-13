# R per proletari - Episodio 02

**R per proletari** è una serie di post LinkedIn con lo scopo di fornire un aiuto
per automatizzare la produzione di report ripetitivi.

In questo episodio 02, il primo dopo il manifesto iniziale del progetto,
iniziamo con la creazione di una sorta di bollettino della qualità dell'aria
utilizzando i dati di ARPA Emilia-Romagna relativi alle misure di contaminanti
atmosferici nelle centraline della provincia di Reggio Emilia.

## Obiettivi

- Scaricare i dati dalle API di 
[**ARPA Emilia-Romagna**](https://dati.arpae.it/datastore/dump/4dc855a1-6298-4b71-a1ae-d80693d43dcb).
- Elaborare e valutare i dati secondo i criteri del 
[**Decreto Legislativo 155/2010**](https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.legislativo:2010-08-13;155).
- Generare un report in formato Quarto analogo a un bollettino della qualità 
dell'aria per la provincia di **Reggio Emilia**.

## Struttura del progetto

- `R/` – funzioni per scaricare ed elaborare i dati.
- `data/` – dati scaricati dalle API.
- `report.qmd` – documento Quarto per la generazione del bollettino.
- `output/` – report generati.
- `init.R` – script per inizializzare l'ambiente con renv.
- `renv/` + `renv.lock` – gestione dell'ambiente con **renv**.

## Requisiti

- **R >= 4.2**
- **Quarto** installato (https://quarto.org)
- Tutti i pacchetti R sono gestiti tramite **renv**.

## Setup

1. Clonare il repository:

   ```bash
   git clone https://github.com/<tuo-username>/<repo>.git
   cd <repo>
   ```

2. In R, lanciare lo script di inizializzazione:

   ```r
   source("init.R")
   ```
   
3. Generare il report

   ```bash
   quarto render report.qmd
   ```
   
## Criteri di valutazione dei dati secondo il Decreto Legislativo 155/2010

Il report confronta i dati osservati con i valori limite di legge, ad esempio:

- PM10 → media giornaliera ≤ 50 µg/m³ (max 35 superamenti/anno).
- NO₂ → max oraria ≤ 200 µg/m³ (max 18 superamenti/anno).
- O₃ → max media mobile 8h ≤ 120 µg/m³ (max 25 superamenti/anno).
- CO → max media mobile 8h ≤ 10 mg/m³.
- SO₂ → max giornaliera ≤ 125 µg/m³ (max 3 superamenti/anno).
- SO₂ → max oraria ≤ 350 µg/m³ (max 24 superamenti/anno).

## Output

Il report finale include:

- Una mappa dei punti di monitoraggio (con `ggplot2` + `ggmap`).
- Tabelle di confronto tra valori osservati e limiti normativi.
- Grafici temporali delle concentrazioni.

## Prossimi sviluppi

- Estensione ad altre province dell'Emilia-Romagna.
- Automazione programmata (GitHub Actions o `cron`).
