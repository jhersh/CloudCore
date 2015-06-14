# CloudCore

[![Circle CI](https://circleci.com/gh/jhersh/CloudCore.svg?style=svg)](https://circleci.com/gh/jhersh/CloudCore) [![Version](https://img.shields.io/cocoapods/v/SPLCloudKitWidget.svg?style=flat)](http://cocoapods.org/pods/SPLCloudKitWidget)

CloudCore is a bridge between your local Core Data records and your remote CloudKit entities. Core Data is fast, but persisted locally, while CloudKit records are fetched over the network and available to the current user's iCloud account on any device. CloudCore is the chocolate and peanut butter treat that fills you up and never lets you down. 

CloudCore has two components:

- Categories on `CKDatabase`, `CKRecord`, `CKQuery`, and other CloudKit objects to assist with querying, serializing and deserializing, and fetching and saving records
- An adapter object, `CCOCloudCore`, that aims to provide two-way synchronization between your Core Data records locally and your CloudKit records remotely.

(A work in progress)

CloudCore is a [Jonathan Hersh](https://github.com/jhersh) production and is available under the MIT license. See the `LICENSE` file for more info.
