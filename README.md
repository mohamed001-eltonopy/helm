# Helm

Helm is a package manager for kubernetes like apt,yum, So it used to ("package" Yaml files) and "push" them into public or private repositories

## Difference between Helm2 and Helm3 :

Helm2 Consists of 2 parts :

CLIENT (helm cli): 					
	  when ever you deploy a helm chart,then helm client will send the "yaml files" to tillers that actually run in a kubernetes cluster 

SERVER (Tiller):  
     it's run in a kubernetes cluster and executes the request that send from "helm cli"
	   and create a component from this yaml files inside kubernetes cluster
     tiller will store any configuration you did "create,change deployment" so you can rollback to any previous version
	
Helm v3:
	 Delete Tiller becouse it consumped a lot of power inside kubernetes cluster
  
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
helm create microservice

```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)
