This repository was created as the Ruby on Rails technical assignment for Mews 

## Table of contents
- [Task description](#task-description)
- [Assumptions](#assumptions)
- [Proposed solution](#proposed-solution)
- [Future improvements](#future-improvements)


### Task description 
The task is to implement a fully functional ExchangeRateProvider for the Czech National Bank. 
The data used is extracted from their website.
The application should expose a simple REST API (ideally JSON), adding some UI would be beneficial for full-stack applications.
The solution has to be buildable, runnable and the test program should output the obtained exchange rates. 

### Assumptions
- Since we are dealing with exchange rates, and the value can change, we are not saving the information provided by the endpoints to the database, and we are using the service as a consulting tool.

### Proposed solution
This project uses a simple basic Ruby on Rails application, that exposes a very basic UI, so the customer can interact with the endpoints in an easier way.
The api includes versioning, allowing future updates without affecting current users.
The service to fetch the exchange rates is cached for 24 hours, as the input file that we use from the Czech bank uses the word daily, so we understand this information is udpated every 24 hours.
The API expose the following endpoints;
- `/api/v1/exchange_rates` → Lists all the currencies exchange rate

### Future improvements
- Provides Swagger documentation and testing endpoints.