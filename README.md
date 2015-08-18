# PM25-iOS [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

这是一个 pm25.in 的 wrapper 框架。该框架提供了 Swift 2.0 环境下查询中国城市空气指数的 API。

This is a wrapper around `pm25.in`, which provides API to air quality data in various Chinese cities.

## 概要 Overview

1. 使用框架 Use framework

  `PM25` 目标会被编译成框架。把这个框架拖进你的工程，在 `Add target dependency` 中添加对它的依赖。

  First, build source files in `PM25` target as a framework and add target dependency to that from your project.

  导入 `PM25` 框架：

  In the files you want to use this framework, simply do

      import PM25

  请去 `pm25.in` 申请一个 access token，在使用任何的 API 之前请设置如下：

  Please apply for an access token at `pm25.in`, and type the following line before using any API:

      PM25Manager.sharedManager.token = "YOUR TOKEN HERE"

  `PM25` 框架下的 `Query` 是个 enum，其中的每个 case 代表了一种查询：

  The `Query` enum contains several cases, each representing a type of query.

      case CityPM2_5(city: String, fields: CityQueryField)
      case CityPM10(city: String, fields: CityQueryField)
      case CityCO(city: String, fields: CityQueryField)
      case CityNO2(city: String, fields: CityQueryField)
      case CitySO2(city: String, fields: CityQueryField)
      case CityO3(city: String, fields: CityQueryField)
      case CityAQI(city: String, fields: CityQueryField)
      case CityDetails(city: String)
      case StationDetails(stationCode: String)
      case StationList(city: String?)
      case CityNames
      case AllCityDetails
      case AllCityRanking

  其中 `CityQueryField` 是指定返回数据的设置，`CityQueryField.Stations` 会包含所有监测站的数据；`CityQueryField.Average` 只会包含一个该城市所有监测站的平均数据；`CityQueryField.Default` 则会包含两者。您可以用 `DataSample` 类中的 `-isAverageSample` 区分是否一组监测数据是平均数据还是来自监测站的单独数据。

  Use `CityQueryField` to set the samples you wish to get back from each of the city-related query. Setting `CityQueryField.Stations` will include the samples from all monitoring stations from current city; setting `CityQueryField.Average` will only include the average data of all monitoring stations; setting `CityQueryField.Default` will include both of above. To differentiate if a `DataSample` instance is the average value or an individual sample, please use its `-isAverageSample` property to do so.

  想要执行一个查询，只需要这么做：

  To execute a query, simply do something like

      Query.AllCityDetails.executeQuery { result, error in
          // Do something
      }

  用其中 result?.samples 就可以得到一个 `DataSample` 类型的数组。

  Use `result?.samples` to access the list of `DataSample` instances that contains air quality data.

  如果你的查询是 `CityNames` 请访问 `result?.cities`；如果你的查询是 `StationList(city: String?)` 请访问 `result?.monitoringStations`.

  Note: if you query `CityNames` the previous field will be `nil`. please access `result?.cities` instead. Similarly if you query `StationList(city: String?)` please access `result?.monitoringStations`.

## 要求 Requirement

Xcode 7 beta 5, Swift 2.0.

## 示例应用 Sample app

该工程包含了一个示例应用供您借鉴把玩。

This project also contains a sample app for you to play with.

![Screenshot](https://raw.githubusercontent.com/DJBen/PM25-iOS/master/Images/PM25Screen.png)

## 贡献 Contributions

欢迎任何形式的贡献，包括但不限于开 issue，给 pull request，或者给我发邮件！

All kinds of contributions are welcome!
