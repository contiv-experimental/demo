The purpose of this document is to demonstrate the current implementation of service loadblancer support for docker

##What is a Service ? What are providers for a service
A service is an abstration to provide a network connection  on a set of ports to a cluster of containers matching the service 
label-selector. Services are easy to scale up/down. Services provide efficient loadbalancing and minimal downtime. 
A provider can be one or many containers that match the label selector associated with the services. 










##How is a Service defined

Current implementation allows services to be defined using netctl. Services need to be created in a service subnet.
```

```

##How to add providers to a service

Providers can be associated with a service by starting with matching labels.
```
```

##Demonstration of reachability to a service

