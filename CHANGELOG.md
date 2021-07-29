# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- processing group information did not take into account that the user may have no groups assigned (#14) 

## [v1.4.2] - 2021-07-28
### Fixed 
- remove conditional require

## [v1.4.1] - 2021-07-27
### Added
- Troubleshooting guide for importing ruby projects into IntelliJ

### Fixed
- Repaired basic auth authentication for (#8)

## [v1.4.0] - 2021-07-26
### Added
- Option to authenticate with Proxy Ticket (#6)

## [v1.3.1] - 2021-04-21
### Fixed
- Fixed a bug regarding the creation of users that lead to internal server errors

## [v1.3.0] - 2021-04-20
### Added
- A new model that provides authentication via the cas. 
  Originally this implementation was inside the dogu. 
  However as integral part of the plugin it was moved to here to prevent redundancies.

### Fixed
- a bug that removed the admin privileges from redmine admin users after a request to the redmine_cas api

## [v1.2.15] - 2020-11-16
### Added
- functionality to enable a redirect from login page to cas login when anonymous access is activated
- scripts for easier development in EcoSystem

### Fixed
- redirect loop when logging in with cas when anonymous access is activated
