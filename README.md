👉 We've also built [Jumpstart Pro](https://jumpstartrails.com) which is a version of Jumpstart that includes payments with Stripe & Braintree, team accounts, TailwindCSS, and much more.

# Jumpstart Rails Template

All your Rails apps should start off with a bunch of great defaults. It's like Laravel Spark, for Rails.

**Note:** Requires Rails 5.2 or higher

Want to see how it works? Check out [the Jumpstart walkthrough video](https://www.youtube.com/watch?v=ssOZpISfIfI):

[![Jumpstart Ruby on Rails Template Walkthrough](https://i.imgur.com/pZDPbc7l.png)](https://www.youtube.com/watch?v=ssOZpISfIfI)

## Getting Started

Jumpstart is a Rails template, so you pass it in as an option when creating a new app.

#### Requirements

You'll need the following installed to run the template successfully:

* Ruby 2.5 or higher
* Redis - For ActionCable support
* bundler - `gem install bundler`
* rails - `gem install rails`
* Foreman (optional) - `gem install foreman` - helps run all your
  processes in development

#### Creating a new app

```bash
rails new myapp -d postgresql -m https://raw.githubusercontent.com/sikandartariq1/jumpstart/master/template.rb
```

Or if you have downloaded this repo, you can reference template.rb locally:

```bash
rails new myapp -d postgresql -m template.rb
```

#### Cleaning up

```bash
rails db:drop
spring stop
cd ..
rm -rf myapp
```
