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
