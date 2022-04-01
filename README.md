# Weather API with Server-Side Swift

<p align="center">
<img
src="https://img.shields.io/badge/vapor-41C4FF.svg?style=for-the-badge&logo=vapor&logoColor=white"
/>
<img
src="https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white"
/>
<img
src="https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white"
/>
<img
src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white"
/>
</p>

This is a **demo server** created for the article "*[Async/Await in Vapor — How to create a weather API with Server-Side Swift](https://medium.com/@mattia.fochesato/async-await-in-vapor-how-to-create-a-weather-api-with-server-side-swift-b305b646654e?source=friends_link&sk=28a30d78ba247617cf64e96f466d4a31)*"

You are going to discover how to fetch the weather from OpenWeatherMap (abbreviated to OWM). The goal is to learn how to design and create an API Endpoint that needs to execute some tasks before returning the result to the client. It can be achieved easily with the new `async`/`await` operators.

The final application will make **two** **parallel** requests to OWM to get **detailed weather** data, **combine** the results and **return** it to the client.

Of course, OpenWeatherMap already has an API Endpoint (One Call) that gives all those information but as said before, the goal of this article is to learn how to work with concurrency with Vapor.


## Final Result
<img align="center"
src="https://cdn-images-1.medium.com/max/1600/1*T3-4Y9horccVA-QPTi9XKA.png" alt="http://127.0.0.1:8080/weather?lat=40.851799&lon=14.268120">
<p align="center">
<a href="http://127.0.0.1:8080/weather?lat=40.851799&lon=14.268120">http://127.0.0.1:8080/weather?lat=40.851799&lon=14.268120</a>
</p>
