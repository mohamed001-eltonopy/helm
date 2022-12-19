# Helm

Helm is a package manager for kubernetes like apt,yum, So it used to ("package" Yaml files) and "push" them into public or private repositories

## Lifecycle management with Helm 
 each time we pull a chart and install it a release which is "your application or a package or collections of kubernetes objects" is created  
 and revision is the upgrade that happened in each release like update an image and so on .


## Difference between Helm2 and Helm3
**Helm2:** Consists of CLIENT (helm cli) when ever you deploy a helm chart,then helm client will send the "yaml files" to tillers that actually run  in a kubernetes cluster.And SERVER (Tiller) that run in a kubernetes cluster and executes the request that send from "helm cli" and create a component from this yaml files inside kubernetes cluster  
**Helm3:** Delete Tiller becouse it consumped a lot of power inside kubernetes cluster

## Installation

From Homebrew (macOS)

```bash
brew install helm
```

## Helm is useful in:

"templating engine": 
      if you have many microservices in your cluster and each of them has it's "deployment and service " and almost the same values
      So each dynamic values will replaced by palceholders and that will be a "Template file" and each value in yaml file "Template file" 
      take the value from external configuration yaml file called "values.yaml" ex:  name: {{ .Values.name }} 
      
## Helm Chart:
"Bundle of yaml files" and it created using (helm) and pushing them to "helm repositorie" to be available

## Helm Chart structure: 

mychart/ : name of chart

Chart.yaml: meta info about chart ex: name , dependencies , version

values.yaml: are the default values for the template file 

charts/ : chart dependencies if this chart depend on other chart this chart will define here

templates/ : the actual template files

## Helm Commands:
```bash
# create helm chart
helm create microservice-release
# testing purpose >> see your release with its values before deployed
helm template ./webapp/
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






