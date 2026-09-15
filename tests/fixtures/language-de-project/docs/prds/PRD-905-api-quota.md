---
id: PRD-905
title: API quota per client
status: draft
date: 2026-08-13
---

# PRD-905: Nutzungsgrenze pro Kunde

## Why this matters for the client

Ein einzelner Kunde kann heute so viele Anfragen senden, dass die Antwortzeit
fuer alle anderen steigt. Die Grenze wird pro Token gezaehlt und nicht pro
Konto, weil ein Konto mehrere Token haben kann und weil der Cache sonst fuer
jeden Kunden neu gefuellt werden muss. Der Endpoint meldet die verbleibende
Menge im Kopf der Antwort, damit ein Client seine Last selbst steuern kann.

## What is in scope and what is not

Die Zaehlung, der Webhook und das Protokoll gehoeren dazu. Ein Timeout auf der
Verbindung gehoert nicht dazu, und die Abrechnung bleibt unveraendert. Wer die
Grenze erreicht, bekommt eine klare Meldung und nicht einfach einen Fehler.

Die Werte stehen in `X-RateLimit-Remaining` und unter `/v1/tokens`, damit jede
Bibliothek sie ohne weitere Absprache lesen kann.

| Grenze | is applied for each Token | not the client |
|---|---|---|
| Fenster | eine Stunde | rollierend |

## How the limit is measured over time

Die Messung laeuft ueber ein rollierendes Fenster, weil ein festes Fenster am
Anfang jeder Stunde eine Spitze erzeugt und weil die Spitze genau dann kommt,
wenn viele Kunden gleichzeitig neu beginnen. Siehe
[Messwerte](../notes/about-the-quota-and-the-limit.md) und
https://example.test/about-the-quota-and-the-limit fuer die Herleitung.

```
the counter is reset by the worker that is scheduled for the window, and
the value that is written here is the one that the endpoint reads, so if this
and the header disagree then the worker is behind and not the limit itself.
```
