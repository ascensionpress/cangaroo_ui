# CangarooUI

A lightweight and production-ready user interface for [cangaroo](https://github.com/nebulab/cangaroo/) that emulates the functionality of Wombat:

* view jobs as they happen
* track payloads as they move through the system
* search for errors, orders, payloads
* edit JSON payloads and resend
* retry failed jobs
* resolve errors

### Screenshots

![image](https://user-images.githubusercontent.com/7997618/35738958-387e106c-07fe-11e8-8306-9b6b1a83c2fb.png)

![image](https://user-images.githubusercontent.com/7997618/35738996-56de08aa-07fe-11e8-9982-7f38a1c1e917.png)

### Design Goals
* __optional__
   * users have to opt-into the interface as an add-on to cangaroo -- by
     default, cangaroo doesn't change
   * backwards-compatible for existing users to upgrade to the newest version
   * users can decide on a per-job basis whether they want that job tracked in
     the GUI
* __general__
  * support PushJobs and PollJobs
  * any payload type
  * any DB type
  * any worker (delayed_job, sidekiq, resque, etc -- though only delayedjob is
    currently supported)
* __minimal__
  * no monkey-patching
  * no modifications to the cangaroo core
  * only three new DB tables and some ActiveJob callbacks
* __simple__
  * track jobs through the GUI with a single `include` in the job class
  * no authentication (leaves people free to use Devise, HTTP Basic, or whatever
    else they want)
  * no fancy JS to pre-compile or anything, not even jQuery
  * bootstrap styles in vanilla CSS

### Installation

Add both cangaroo and the cangaroo_ui gems to your gemfile:

``` ruby
  gem 'cangaroo', github: 'nebulab/cangaroo', branch: 'master', ref: 'b681d60f4ab40e87781'
  gem 'cangaroo_ui'
```

NOTE: for now, it's
[essential](https://github.com/nebulab/cangaroo/issues/57#issuecomment-367443046)
that you bundle the version of cangaroo in Github. The version in rubygems is
out of date and will not work with the interface.

Next, copy the following migrations into your `db/migrate` folder and then run
them with `bundle exec rake db:migrate`:

* [create
  records](https://github.com/ascensionpress/cangaroo_ui/blob/master/db/migrate/20180126171621_create_records.rb)
* [create
  transactions](https://github.com/ascensionpress/cangaroo_ui/blob/master/db/migrate/20180126204846_create_transactions.rb)
* [create_resolutions](https://github.com/ascensionpress/cangaroo_ui/blob/master/db/migrate/20180205152255_create_cangaroo_resolutions.rb)

Next, mount the engine somewhere in the host application's routes file:

```ruby
  Rails.application.routes.draw do
    mount CangarooUI::Engine => "/"
  end
```

Finally, configure the jobs you want tracked by adding the
`CangarooUI::InteractiveJob` mixin to them, e.g.:

```ruby
  module Spree
    class UpdateShipmentJob < Cangaroo::PushJob
      include CangarooUI::InteractiveJob # just add this to track in the UI!!

      connection :spree
      path '/update_shipment'
      process_response false

      ....
    end
  end
```

`CangarooUI::InteractiveJob` can be added to both PushJobs and PollJobs.

For PollJobs, the mixin also makes available the `::on_success_resolve_duplicates`
class method, which will configure the UI to automatically resolve duplicate
poll jobs once one succeeds.

```ruby
  module Spree
    class PollShipmentsJob < Cangaroo::PollJob
      include CangarooUI::InteractiveJob

      connection :spree
      path '/get_shipments'
      frequency 3.minutes

      on_success_resolve_duplicates true
    end
  end
```

This configuration is completely optional, and defaults to false.

And that's it! You should be up and running in no time.
