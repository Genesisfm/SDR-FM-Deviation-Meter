# SDR# FM Deviation Meter

SDR# plugin voor WFM controlemetingen:

- FM deviation piek en RMS
- RDS power rond 57 kHz
- FM signaalsterkte in dBFS
- pilotniveau rond 19 kHz

De plugin registreert zich op de SDR# MPX/consumer stream wanneer die beschikbaar is. Als een SDR# build die streamnaam anders noemt, probeert de plugin enkele bekende alternatieven en valt als laatste terug op `FilteredAudioOutput`.

## Build

1. Download de SDR# Plugin SDK van Airspy.
2. Kopieer uit de SDK de bestanden naar `lib`:
   - `SDRSharp.Common.dll`
   - `SDRSharp.Radio.dll`
3. Build:

```powershell
.\build.ps1
```

## Installatie

```powershell
.\install.ps1 -SdrSharpRoot C:\SDRSharp
```

Bij moderne SDR# builds is kopieren naar `C:\SDRSharp\Plugins\FmMeter` genoeg. Voor oudere builds voeg je in `C:\SDRSharp\bin\Plugins.xml` toe:

```xml
<add key="FM Deviation Meter" value="SDRSharp.FmMeter.FmMeterPlugin,SDRSharp.FmMeter" />
```

## Kalibratie

De deviation-meter gebruikt `75 kHz` als 100%-referentie. De SDR# MPX-stream is genormaliseerd; daarom staat de standaardschaal op `35,0 kHz` per MPX-unit. De schaal is in het pluginpaneel aanpasbaar, zodat je hem kunt ijken met een bekende FM meetzender of een betrouwbare referentie.

De piekmeting gebruikt standaard het `99,5%` percentiel. Dat voorkomt dat ultrakorte MPX-spikes de meter continu te hoog laten staan. Wil je juist een hardere echte piekindicatie, zet `Piek percentile` hoger, bijvoorbeeld `99,9`.

Het paneel toont ook `Trend gem.`. Dat is een langzaam lopend gemiddelde van de piekdeviation, plus een kleine trendgrafiek met een rode 100%-lijn. Gebruik die trendwaarde om te beoordelen of een station structureel te hoog staat; de directe piekwaarde blijft bedoeld voor korte uitschieters.

RDS power wordt weergegeven als dB boven de lokale hoogfrequente MPX-ruisvloer en als percentage van de totale MPX energie. Dat is bedoeld als praktische live-indicator, niet als vervanging voor een gecertificeerde broadcast analyzer.
