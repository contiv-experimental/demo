The purpose of this document is to demonstrate the current implementation of service loadblancer support for docker

##What is a Service ? What are providers for a service
A service is an abstration to provide a network connection  on a set of ports to a cluster of containers matching the service 
label-selector. Services are easy to scale up/down. Services provide efficient loadbalancing and minimal downtime. 
A provider can be one or many containers that match the label selector associated with the services. 

##How is a Service defined

Current implementation allows services to be defined using netctl. Services need to be created in a service network. So we create a service subnet and attach  the service to the service network
```
netctl net create cisco-srv-net -s 100.1.1.0/24

netctl service create app-svc --network cisco-srv-net --tenant default --selector=app=myapp --port 8080:80:TCP
```

##How to add providers to a service

Providers can be associated with a service by starting with matching labels. In the following example we create a network cisco-net which will be used by the 4 providers created with labels matching the service selector. Start listeners on each of the providers.
```
netctl net create cisco-net -s 10.1.1.0/24

docker run -itd --net=cisco-net --label=app=myapp alpine sh
2c30b978c87bad64ced1f8158b72d17abf7748889464023d4e23a4bd24ae2d28

docker run -itd --net=cisco-net --label=app=myapp alpine sh
3a23aa2d5891153999871544362b881fcd461e46021007453e0e6e7edf06b348

docker run -itd --net=cisco-net --label=app=myapp alpine sh
ef6691ebb26ea54749242606ec23be01903f886f58382e346ec61369aab39073

docker run -itd --net=cisco-net --label=app=myapp alpine sh
2a3ac3917e54775081e2afc40ce6d718e7871d4814a6fd387ecf4eca16fc2474

docker exec -it 


```

##Demonstration of reachability to a service from the client containers





