# CFA-find-a-way

A terminal program that takes in an origin and destination, prints out the distant and time to destination, and gives the user the option of printing directions on screen and saving directions into .txt file.

## About the Project

This program is an extension on a team project we did in class. The part of the project that I worked on used a google maps api gem to access the duration and time between an address a user entered and a few randomly selected hard coded addresses. 

The program added the function of acquiring the directions from a user entered address to another user entered address. It also adds the option of asking the user if they want to print out the address and/or save the address to a file. It still prints out the duration and distance between the 2 addresses

## Requirements

- Ruby 2.0 or later.
- Terminal Table by tj
- Google Maps Service Api by edwardsamuel
- A Google Maps API credentials (API keys or client IDs)
- config file for API key.

## Installation

Add this line to your application's Gemfile:

  `gem 'google_maps_service'`

And then execute:

  `$ bundle install`

Or install it yourself as:

  `$ gem install google_maps_service`

To install the terminal table gem:

  `$ gem install terminal-table`

### Obtain API keys

Each Google Maps Web Service requires an API key or Client ID. API keys are freely available with a Google Account at https://developers.google.com/console. To generate a server key for your project:

    1. Visit https://developers.google.com/console and log in with a Google Account.
    2. Select an existing project, or create a new project.
    3. Click Enable an API.
    4. Browse for the API, and set its status to "On". The Python Client for Google Maps Services accesses the following APIs:
       - Directions API
       - Distance Matrix API
       - Elevation API
       - Geocoding API
       - Time Zone API
       - Roads API
    5. Once you've enabled the APIs, click Credentials from the left navigation of the Developer Console.
    6. In the "Public API access", click Create new Key.
    7. Choose Server Key.
    8. If you'd like to restrict requests to a specific IP address, do so now.
    9. Click Create.

Your API key should be 40 characters long, and begin with AIza.

Important: This key should be kept secret on your server. The config file you create will contain the API key. Inside the file will look like this:

  `class Config
    API_KEY = 'YOUR_API_KEY_HERE'
   end`

## Usage

In the terminal:

  `ruby find_a_way_complete.rb`
  
Follow the instructions. Enjoy

## Known Bugs

It will only work for origin and destination addresses that are in the same country. There's no way for the Google Maps system to get directions across oceans... yet.
