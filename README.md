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
- `/api/v1/exchange_rates/currency` → Displays the exchange rate for a specific currency
- `/api/v1/exchange_rates/convert` → Displays a form accepting an amount and dropdown to select the currency and returns the exchange of said amount in CZK 

### Future improvements
- Provides Swagger documentation and testing endpoints.
- Provide better styling in the views 
  - Use font-size instead of h1
  - Add classes for styling 
- Enhance form protection. At the moment we use `form_for`to get the input from the user and process the exchange rate request, and though the form comes with built in security, we could further protect the application by validating the inputs or using strong parameters in the controllers to avoid data injection. 