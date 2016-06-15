The purpose of this document is to demonstrate the current implementation of service loadblancer support for docker

##What is a Service ? What are providers for a service
A service is an abstration to provide a network connection  on a set of ports to a cluster of containers matching the service 
label-selector. Services are easy to scale up/down. Services provide efficient loadbalancing and minimal downtime. 
A provider can be one or many containers that match the label selector associated with the services. 

##How is a Service defined

Current implementation allows services to be defined using netctl cli option or using Rest APIs. Services need to be created in a service network. So we create a service network and attach  the service to the service network. Requirements for services is defined in the form of selectors. Selectors are key/value pairs which is used to group providers with matching labels. In the following example we are creating a web service in a web-tier and providers needs to be stable and production ready.
```
netctl net create contiv-srv-net -s 100.1.1.0/24

netctl service create app-svc --network contiv-srv-net --tenant default --selector=tier=web --selector=release=stable --selector=environment=prod --port 8080:80:TCP
```

##How to add providers to a service

Providers can be associated with a service by starting with matching labels. In the following example we create a network contiv-net which will be used by the 4 providers created with labels matching the service selector. Start listeners on each of the providers.
```
netctl net create contiv-net -s 10.1.1.0/24 -g 10.1.1.254

docker run -itd --net=contiv-net --label=tier=web --label=release=stable --label=environment=prod --label=version=1.0 alpine sh
2c30b978c87bad64ced1f8158b72d17abf7748889464023d4e23a4bd24ae2d28

docker run -itd --net=contiv-net --label=tier=web --label=release=stable --label=environment=prod --label=version=1.0 alpine sh
3a23aa2d5891153999871544362b881fcd461e46021007453e0e6e7edf06b348

docker run -itd --net=contiv-net --label=tier=web --label=release=stable --label=environment=prod --label=version=1.0 alpine sh
ef6691ebb26ea54749242606ec23be01903f886f58382e346ec61369aab39073

docker run -itd --net=contiv-net --label=tier=web --label=release=stable --label=environment=prod --label=version=1.0 alpine sh
2a3ac3917e54775081e2afc40ce6d718e7871d4814a6fd387ecf4eca16fc2474

```

##Demonstration of reachability to a service from the client containers

Start listeners on each of the providers.

```
docker exec -it 2c30b978c87bad64ced1f8158b72d17abf7748889464023d4e23a4bd24ae2d28 sh
#nc -l -p 80 &

docker exec -it 3a23aa2d5891153999871544362b881fcd461e46021007453e0e6e7edf06b348 sh
#nc -l -p 80 &

docker exec -it ef6691ebb26ea54749242606ec23be01903f886f58382e346ec61369aab39073 sh
#nc -l -p 80 &

docker exec -it 2a3ac3917e54775081e2afc40ce6d718e7871d4814a6fd387ecf4eca16fc2474 sh
#nc -l -p 80 &
```

Create a network for clients/consumers and start containers. Try to reach the service ip(service ip allocated in our example is 100.1.1.3) on the service port

```
netctl net create client-net -s 11.1.1.0/24 -g 11.1.1.254

docker run -itd --net=client-net  alpine sh
9e6842a59369ba67d6224c1502ab0e68360fe7aaa0949a04462a9ae0bdbc6830

docker exec -it 9e6842a59369ba67d6224c1502ab0e68360fe7aaa0949a04462a9ae0bdbc6830 sh
# nc -znvw 1 100.1.1.3 8080
100.1.1.3 (100.1.1.3:8080) open
```

Note: Service IP can also be a preferred ip address. This can be enforced while creating the service configuration with -ip option.
Coming Soon: Watch for more intuitive contiv-compose integration. 








