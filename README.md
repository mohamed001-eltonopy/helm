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
## Named Templates and Indentation func.
- you might see in deployment file "labels" that are repeated multiple times throughout this file or in other objects like service.yaml and so on.
```go
metadata:
  name: {{ .Relase.Name }}-nginx
  // Here we have a bunch of labels defined  multiple times throughout this deployment.yaml file
  labels:
    app.kubernetes.io/name: {{ .Relase.Name }}
    app.kubernetes.io/instance: {{ .Relase.Name }}
```
We can remove the repeating lines by using **"named template"**:
1-We move the repeating lines to a file called _helpers.tpl file "this file not consider as a usual template file" Because when we run
the helm create command, helm reads all the files in the templates directory and converts them to Kubernetes manifests except this file.
"So any file starting with an (_) are skipped from being converted into a Kubernetes manifest file."
- [Named Templates in helm](https://helm.sh/docs/chart_template_guide/named_templates/#helm)
```go
// We can then give these lines or this template a name using the define statement like this inside (_helper.tpl) file.
{{- define "labels" }}
    app.kubernetes.io/name: {{ .Relase.Name }}
    app.kubernetes.io/instance: {{ .Relase.Name }}
{{- end }}    
```
Now, these lines can now be imported, or rather included anywhere we want using a simple template statement like this in deployment file for example:

```go
metadata:
  name: {{ .Relase.Name }}-nginx
  //you define what helper template you’d like to use and we used "." to refers to the current scope and it is then accessible from within the helper file
  labels:
    {{- template "labels"  . }}
```
But still there's an issue as The template statement added the lines from the helper file,with the same indentation for all the labels 
and thus resulting in a file that’s not formatted correctly, and we will fix that issue using "Indentation"
**Indentation with "include"func** 
- [Indentation in helm](https://helm.sh/docs/chart_template_guide/yaml_techniques/#indenting-and-templates)
There is a function that helps fix the spaces in helm template which is "indent", 
Also we can't use "template" to import named template from _helper.tpl with indent func as  template is not a function, it is an action.
So, Another function that does the same job as template is the "include" function, it can import a named template,and also pipe it to another function.
```go
spec:
  selector:
    matchLabels:
      {{- include "labels"  . | indent 2 }}
```

## Chart Hooks
extra actions are implemented with what is known as hooks.
When a user installing various Kubernetes objects to get our app up and running, they can do some extra stuff too For example:
we can write the charts in such a way that whenever we do a Helm upgrade,install,  a database can be automatically backed up before the upgrade,install 
so we can restore db from backup, OR it could be sending an email alert before an upgrade operation.
**For Example**:
we want to take a backup of the database before the chart is actually upgraded, se We use the pre-upgrade hook.
The pre-upgrade hook runs a predefined action which in our case " to take a backup of the database." So Helm waits for this action to be completed
 before proceeding to the final phase of installation or upgrading applications on Kubernetes. And then After the upgrade phase, we'd like to perform
some kind of cleanup activity So For this, we add a post-upgrade hook , The post-upgrade hook runs after the install phase is successful 
and performs actions such as sending an email status 
**how these hooks are configured**
Say you have a script to back up the database called backup.sh, how do you get that script executed by Kubernetes?
So You develop the script, and then run it as "job" as we want the script to be run once "We know that a pod runs forever", 
and runs the backup script using an Alpine image, and this file is placed along with the other templates directory "deployment,service,secret" 
let we called it **backup-job.yaml** It has to be run before the install phase as a pre-installed hook 
```go
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Relase.Name }}-nginx
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: pre-upgrade-backup-job
        image: "alpine"
        command: ["/bin/backup.sh"] 
 ```
So,How do we differentiate the chart hook from the normal template files? How do you tell Helm that this job that we've created is a pre-upgrade hook
and not a usual template? 
For this, we add an **annotation** which is a way for us to add additional metadata to an object which may be used by clients of Kubernetes
in this case, Helm, to store data about that object and perform some kind of actions. 
So, We add an annotation with the key **helm.sh/hook: pre-upgrade**  This configures this job as a pre-upgrade hook 
```go
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Relase.Name }}-nginx
  annotations:
    # This is what defines this resource as a hook. Without this line,
    # job is considered part of the release.
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "-4"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: pre-upgrade-backup-job
        image: "alpine"
        command: ["/bin/backup.sh"] 
 ```
**multiple hooks with setting a weight**
We can have multiple hooks configured for each step. 
For example, we can have multiple pre-upgrade hooks configured. This could be for performing other activities.
How do we define in what order these hooks are to be executed? 
We set a weight for each job in the order they should be run. Helms sorts these in ascending order (-4,1,3) and so on.
To set a weight for a hook we add an annotation with the key **helm.sh/hook-weight": "-4"** 
What happens after the backup job is completed? The resource created for the hook, which is, in this case,is the job resource is going to stay on
as a resource on the cluster We can configure them to be cleaned up by setting **hook deletion policies**
we add the annotation **"helm.sh/hook-delete-policy": hook-succeeded**  and set a supported value (hook-succeeded,hook-failed,before-hook-creation)
Now, hook-succeeded deletes the resource after the hook is successfully executed.Now, of course, this means that if the hook fails to execute,
the resources won't be deleted 

- [Chart Hooks in helm](https://helm.sh/docs/topics/charts_hooks/#helm)
- [Writing a Hook](https://helm.sh/docs/topics/charts_hooks/#writing-a-hook)












