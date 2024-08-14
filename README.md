### I&E statements challenge
Build an API application that enables customers to create income and expenditure statements. This application should also calculate disposable income and provide an I&E rating of the customer.

### Solution
In order to achivee the scope of the challenge I have create a Rails API project.

We have confirmed that for this project the users will be also the customers.

In order to create and authenticate users I have used Devise with JWT. The users need to sign up  first with the `email, password and name` after that they can login to receive the {{authorization_token}}. This can be found in the Authorizatin headers and is only valid for 60 minutes after that user needs to login again.

All other requests needs to have the {{authorization_token}} in their headers (ex "Authorization: {{authorization_token}}). The available endpoints are described below on the API Documentation section.

The app uses 3 models:
- User: to save user details
- Statement: to save the basic statement details, belongs_to user
- StatementItem: to save the items related to a statement, belongs_to statement

I tried to also standardize the responses using ActiveModel::Serializers.
All the api responses should be JSON, unless I missed some.


### Asumptions
- The statements are created for a perioad of time so I have added `starts_on` and `ends_on`
- The statements should not be deleted (didn't implemented destroy method), as the rating it might be already used somewhere
- The statement can be empty, no incomes or expeditures provided, in this case we could not calculate the rating, so I used 'N/A' instead
- The statement periods can't overlap

### Ruby and rails versions
- Ruby 3.3.0
- Rails 7.1.3.4

### How to run the project
```
gem install bundler
bundle install
rails db:migrate
rails s
```

### How to run the test suite
```
rspec spec
```

### API Documentation

The available endpoints of the API are:

POST http://localhost:3001/signup - Signing up an user

```
curl --location 'http://localhost:3001/login' \
--header 'Content-Type: application/json' \
--data-raw '{
  "user": {
    "email": "nana.falemi@example.org",
    "password": "1234test"
  }
}'
```

Responses:
- 200 OK:

```
{
    "message": "Signed up successfully"
}
```

- 422 Unprocessable Content:

```
{
    "message": "User couldn't be created successfully",
    "errors": [
        {
            "message": "Email has already been taken",
            "field": "email"
        }
    ]
}
```

POST http://localhost:3001/login - Login user

Request:

```
curl --location 'http://localhost:3001/login' \
--header 'Content-Type: application/json' \
--data-raw '{
  "user": {
    "email": "nana.falemi@example.org",
    "password": "1234test"
  }
}'
```

Responses:
- 200 OK:
```
{
    "id": 2,
    "email": "nana.falemi@example.org",
    "name": "Nana Falemi",
    "statements": []
}
```

- 401 Unauthorized:
```
{
  "message": "Invalid email or password"
}
````

If the request is successfull in the response header `Authoriztion` we will receive the `authorization token`, this needs to be send in the headers for all other implemented requests (except /login and /signup)

#### DELETE http://localhost:3001/logout - Logout user

Request:
```
curl --location --request DELETE 'http://localhost:3001/logout' \
--header 'Authorization: {{authorization_token}}'
````

Responses:
- 200 OK:
```
{
    "message": "Logged out successfully"
}
```

GET http://localhost:3001/statements - List all statements for an user

Request:
```
curl --location 'http://localhost:3001/statements' \
--header 'Authorization: {{authorization_token}}' \
--data ''
```

Responses:
- 200 Ok
```
[
    {
        "id": 1,
        "starts_on": "2024-06-01",
        "ends_on": "2024-06-30",
        "disposable_income": "1900.0",
        "income_and_expenditure_rating": "C",
        "statement_items": [
            {
                "id": 1,
                "item_type": "income",
                "description": "Salary",
                "amount": "2800.0"
            },
            {
                "id": 3,
                "item_type": "expenditure",
                "description": "Mortgage",
                "amount": "500.0"
            },
            {
                "id": 4,
                "item_type": "expenditure",
                "description": "Utilities",
                "amount": "100.0"
            },
            {
                "id": 5,
                "item_type": "expenditure",
                "description": "Life Insurance",
                "amount": "300.0"
            }
        ]
    }
]
```
- 401 Unauthorized
```
{
  "message": "You need to sign in or sign up before continuing"
}
```

POST http://localhost:3001/statements - Create statement

```
curl --location 'http://localhost:3001/statements' \
--header 'Authorization: {{authorization_token}}' \
--header 'Content-Type: application/json' \
--data '{
  "statement": {
    "starts_on": "2024-07-01",
    "ends_on": "2024-07-31",
    "statement_items_attributes": [
      {
        "item_type": "income",
        "description": "Salary",
        "amount": 1800
      },
      {
        "item_type": "expenditure",
        "description": "Mortgage",
        "amount": 200
      }
    ]
  }
}'
```

Responses:
- 200 OK:
```
{
    "id": 3,
    "starts_on": "2024-05-01",
    "ends_on": "2024-05-31",
    "disposable_income": "1600.0",
    "income_and_expenditure_rating": "B",
    "statement_items": [
        {
            "id": 8,
            "item_type": "income",
            "description": "Salary",
            "amount": "1800.0"
        },
        {
            "id": 9,
            "item_type": "expenditure",
            "description": "Mortgage",
            "amount": "200.0"
        }
    ]
}
```

- 422 Unprocessable Content

```
{
    "errors": [
        {
            "message": "Oops! The statement period overlaps with an existing statement",
            "field": "base"
        }
    ]
}
```

- 401 Unauthorized
```
{
  "message": "You need to sign in or sign up before continuing"
}
```

PUT/PATCH http://localhost:3001/statements/1 - Update statement

Request:
```
curl --location --request PUT 'http://localhost:3001/statements/3' \
--header 'Authorization: {{authorization_token}}' \
--header 'Content-Type: application/json' \
--data '{
  "statement": {
    "starts_on": "2024-07-01",
    "ends_on": "2024-07-31",
    "statement_items_attributes": [
      {
        "id": 8,
        "item_type": "income",
        "description": "Salary",
        "amount": 1800
      },
      {
        "id":9,
        "_destroy": "1"
      },
      {
        "item_type": "expenditure",
        "description": "Utilities",
        "amount": 100
      }
    ]
  }
}'
```

Responses:
- 200 OK:

```
{
    "id": 3,
    "starts_on": "2024-07-01",
    "ends_on": "2024-07-31",
    "disposable_income": "1700.0",
    "income_and_expenditure_rating": "A",
    "statement_items": [
        {
            "id": 8,
            "item_type": "income",
            "description": "Salary",
            "amount": "1800.0"
        },
        {
            "id": 10,
            "item_type": "expenditure",
            "description": "Utilities",
            "amount": "100.0"
        }
    ]
}
```

- 404 Not Found
```
{
    "message": "The record does not exist"
}
```

GET http://localhost:3001/statements/3 - Show statement details

Request:
```
curl --location 'http://localhost:3001/statements/3' \
--header 'Authorization: {{authorization_token}}'
```

Responses:
- 200 OK
```
{
    "id": 3,
    "starts_on": "2024-05-01",
    "ends_on": "2024-05-31",
    "disposable_income": "1600.0",
    "income_and_expenditure_rating": "B",
    "statement_items": [
        {
            "id": 8,
            "item_type": "income",
            "description": "Salary",
            "amount": "1800.0"
        },
        {
            "id": 9,
            "item_type": "expenditure",
            "description": "Mortgage",
            "amount": "200.0"
        }
    ]
}
```

- 404 Not Found
```
{
    "message": "The record does not exist"
}
```

### To improve
- Adding versioning and pagination (for statments) to the API.
- Adding proper API documentation, just added `rswag` but we need to add requests in order to generate the documentation
- Improve some of the error messages (specially th Devise one, when authentication expired) to match the format of others.
- Fix all rubocop issues