Oppgave 1
- api endpoint
  https://f3c3g704a4.execute-api.eu-west-1.amazonaws.com/Prod/generate 	

- sam_deploy github actions
  https://github.com/ahje938/pgr301_eksamen_70/actions/runs/12001609648/job/33452357691

Oppgave 2
- terraform plan github actions
  https://github.com/ahje938/pgr301_eksamen_70/actions/runs/12020626101/job/33509576348
  
- terraform apply github actions
  https://github.com/ahje938/pgr301_eksamen_70/actions/runs/12020572724/job/33509426385
  
- SQS-queue URL
  https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-70
  
Oppgave 3

image-navn = andersekeberg/java-sqs-client:latest
SQS-url = https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-70	


Tar i bruk en todelt tagge-strategi. 1 tag peker alltid på latest, så det er oversiktlig å se hvilket image som er av den aller nyeste versjonen, mens den andre taggen
blir da commit messagen til push til branch. Føler det blir en veldig oversiktlig måte å gjøre det på da man tar utgangspunkt i at man er et team og kan inngå avtaler om
å lage relevante navn for systematisering av images.

Eksempel:
#tag1 = "andersekeberg/java-sqs-client:fikset-sam_deploy"
#tag2 = "andersekeberg/java-sqs-client:latest"

Oppgave 4
I koden

Oppgave 5.

Automatisering og kontinuerlig levering
Serverless arkitektur søtter en veldig enkel og effektiv opprettelse av CI/CD pipelines, da de integreres godt med verktøy som SAM og Terraform. Funksjoner kan deployes mye raskere sammenlignet med mikrotjenester, noe jeg la veldig godt merke til jo lenger inn i prosessen jeg kom. Bildegenerering gikk fra 10 sekunder pr bilde, til 1-2 sekunder MAKS gjennom SQS-kø. Lambda tilbyr også innebygd støtte for versjonskontroll. Infrastruktur kan også defineres som koide, slik som API Gateways og SQS. Dette gjør bruk av containere ekstremt enkelt og effektivt. Men det har sine svakheter og, da det vil ende opp med et komplisert oppsett under større prosjekter da antallet funksjoner vokser når hver eneste funksjon har sin egen "livssyklus".

Mikrotjenester har det priviliget at verktøyene er velutviklede og effektive. Her støttes det blant annet av Jenkings og GitHub Actions spesielt for containerbaserte applikasjoner. Pipelines her er også ofte mer standardiserte og støttet av container plattformer som f.eks Kubernetes. Et av hovedpunktene er at under utrulling så kan en mikrotjeneste deployes som en helhetlig enhet, dermed gjøre sporing av utrulling veldig enkelt. Noen av svakhetene inkluderer tyngre prosesser i den for at containerbasert deploying krever bygging, versjonering og distribusjon av docker images. Dette kan ta mye tid. Og jeg vil påstå at det er mye mer komplekst på denne måte, og krever vedlikehold av verktøy som kan gjøre pipelines mer komplekse.

Overvåkning
Serverless arkitektur er veldig effektive i den form av at aws cloudwatch tilbyr automatisk logging og metrikker pr funksjon, i tillegg til aws x-ray gir muligheten for å spore forespørsler gjennom funksjoner og tjeneser. 
Svakheter er blant annet at feilsøking kan bli vanskeligere da flere små funksjoner involveres i en arbeidsflyt. Lambdafunksjoner er også kortvarige, dermed blir det vanskelig å analysere/samle minneverdier osv over tid.
Ved mer pågang/fler funksjoner blir cloudwatch-logger potensielt veldig dyre og vanskelig å navigere

Mikrotjenester har plattformverktøy som f.eks Prometheus som gir omfattende overvåkingsmuligheter av container-miljøer. Det finnes også flere gode verktøy for logging og tracing gjennom tjenester som gir helhetlige oversikter over applikasjonsflyter.

Skalerbarhet og kostnadskontroll
I serverless har ting som lambda automatisk skalering ift hvor mange forespørsler. Og du betaler kun for de som faktisk blir tatt i bruk. Det er heller ingen kostnader på inaktive servere når det ikke er forespørsler
Svakhetene her i lambda kommer hovedsakelig av kostnader. Ved veldig mye pågang kan kostnade i aws overgå kostnadene for drift av vanlige servere, men opp til det punktet er det relativt billig.

Mikrotjenester er veldig forutsigbart, infrastrukturen har en satt kostnad uavhengig av pågang. Mens funksjoner i f.eks lambda har tidsbegrensninger, så har mikrotjenester muligheten for konstant ressursbuk.
Dette fører også til mulig "svinn" da man kan ha overskalert kapasitet ift etterspørsel. Og skalering må som regel optimaliseres manuelt, i motsetning til serverless.

Eierskap og ansvar
Serverless er praktisk i den forstand at drifts-kravene er reduserte da skalering og andre infrastruktur-relaterte hendelser skjer automatisk.
Det kan derimot bli litt vanskelig i lengden å følge med på ansvar av funksjoner osv i større prosjekter da det fort kan bli veldig mange og uoversiktlig til tider. Teamet får også mindre kontroll over den udnerliggende infrastrukturen som beskrevet i linjen ovenfor,
dette kan også være en ulempe under visse omstendigheter.

I mikrotjenester derimot så har eieren og teamet full kontroll over hele stacken, infrastrukturen inkludert. Det er også mer oversiktlig som regel i den forstand at man har forskjellige teams til f.eks utviklign og drift
Men utifra det så krever det mer kompetanse og tid for å drive/administrere infrastrukturen. 
