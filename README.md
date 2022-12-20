# Helm

**Helm:** is a package manager for kubernetes like apt,yum, So it used to ("package" Yaml files) and "push" them into public or private repositories

## Lifecycle management with Helm 
 Each time we pull a chart and install it a release which is "your application or a package or collections of kubernetes objects" is created  
 and revision is the upgrade that happened in each release like update an image and so on .


## Difference between Helm2 and Helm3
**Helm2:** Consists of CLIENT (helm cli) when ever you deploy a helm chart,then helm client will send the "yaml files" to tillers that actually run in a kubernetes cluster.And SERVER (Tiller) that run in a kubernetes cluster and executes the request that send from "helm cli" and create a component from this yaml files inside kubernetes cluster  
**Helm3:** Delete Tiller becouse it consumped a lot of power inside kubernetes cluster

## Installation

From Homebrew (macOS)
```bash
brew install helm
```

## Helm is useful in:

**"templating engine"**: 
      if you have many microservices in your cluster and each of them has it's "deployment and service " and almost the same values
      So each dynamic values will replaced by palceholders and that will be a "Template file" and each value in yaml file "Template file" 
      take the value from external configuration yaml file called "values.yaml" ex:  name: {{ .Values.name }} 
      
## Helm Chart:
"Bundle of yaml files" and it created using (helm) and pushing them to "helm repositorie" to be available

## Helm Chart structure: 

**mychart/** : name of chart

**Chart.yaml**: meta info about chart ex: name , dependencies , version

**values.yaml**: are the default values for the template file 

**charts/** : chart dependencies if this chart depend on other chart this chart will define here

**templates/** : the actual template files

## Helm Commands:
```bash
# create helm chart
helm create microservice-release
# testing purpose >> see your release with its values before deployed
helm template ./webapp/
#Try to dry-run the microservice-release chart now.
helm install microservice-release /root/microservice-release/ --dry-run
# list all releases
helm list
# history of partuclar releases
helm history microservice-release
# rollback to previous release 
helm rollback microservice-release 1      ...>> number of revision

```

## Functions in helm 

Functions in helm help transform data from one format to another.
So what we need here is a simple way for our chart to have some default values that it can fall back on in case the users don’t provide anything in their values. yaml file we can do such a thing using "functions" 
The details about arguments that a function takes can be found in the Helm documentation pages.
 - [Functions in helm](https://helm.sh/docs/chart_template_guide/function_list/)
 
```go 
  # this relase had its value from values defined in the values.yaml file
  {{ .Values.image.repository }}     >>     image: nginx
  # if the user didn't enter a value please, provide a default value using default func.
  {{ default "nginx" .Values.image.repository }}     >>     image: nginx
  
  # Another example of using function in helm
  {{ .Values.image.tag | upper | quote }}     >>     name: "NGINX"
```
## Conditionals

We want to conditionally add these lines depending upon whether the variable was defined or no in helm chart 
 - [Conditions in helm](https://helm.sh/docs/chart_template_guide/control_structures/#ifelse)
```go 
  # we can encapsulate the lines that we want to be available in an if conditional block only if the orglabel value is defined.use "-" to ride of spaces
  # If the orglabel value is not set in the values.yaml file, then orglabel won't be available in the output file either.
  {{- if .Values.orgLabel }}
  labels:
     org: {{ .Values.orgLabel }} 
  {{- end }}
  
  #We have if, else if, and else statements in if conditional blocks, in Helm charts 
  {{- if .Values.orgLabel }}
  labels:
     org: {{ .Values.orgLabel }} 
  {{- else if eq .Values.orgLabel "hr" }}  
      org: human resources 
  {{ else }}
     org: business
  {{- end }}
  
  # the common examples whether to create objects of a certain kinds like serviceaccount or not.I want to provide an option for the user 
  # to customize the creation of the service account based on a setting in the values.yaml file.
  # I add a section called service account with a field create set to true, and I only want to create the service account if this field is set to true.
  {{- if .Values.serviceAccount.create }}
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: {{ .Release.Name }}
  {{- end }}
  
```
```go 
apiVersion: v1
metadata:
  name: {{ .Values.configMap.name }}
  namespace: default
kind: ConfigMap
data:
  {{- if eq .Values.environment "production" }}
    APP_COLOR: pink
  {{- else if eq .Values.environment "development" }}
    APP_COLOR: darkblue
  {{- else }}
    APP_COLOR: green
  {{- end }}
```

## With block to specify a scope:

use with block when everything falls under the same scope 
- [Flow Control in helm](https://helm.sh/docs/chart_template_guide/control_structures/#modifying-scope-using-with)

```go 
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.Release.Name }}
data:
  {{- with .Values.app }}
    {{- with .ui  }} 
      background: {{ .bg }}
      forground: {{ .fg }}
    {{- end }}
    {{- with .db  }}
      database: {{ .name }}
      connection: {{ .conn }}
    {{- end }}
  // As The release object is in the root scope, so the only way to access it is using $ that will take you all the way to the root
  release: {{ $.Release.Name }}   
  {{- end }}
```

## Ranges
Looping with the range action to provide a "for each"-style loop.
- [Looping with the range in helm](https://helm.sh/docs/chart_template_guide/control_structures/#looping-with-the-range-action)

```go 
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.Release.Name }}
data:
// we want to list the regions values that defined inside values.yaml in the form of a list or an array with each region inside a quote.
   regions: 
   {{- range .Values.regions }}
   - {{ . | quote }}
   {{- end }}
   
```
```go
{{- with .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $.Values.serviceAccount.name }}
  labels:
    {{- range $.Values.serviceAccount.labels }}
    tier: {{ . }}
    {{- end }}
    app: webapp-color
{{- end }}
```



