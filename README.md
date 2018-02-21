# CangarooUI

A user interface for [cangaroo](https://github.com/nebulab/cangaroo/)

![image](https://user-images.githubusercontent.com/7997618/35738958-387e106c-07fe-11e8-8306-9b6b1a83c2fb.png)

![image](https://user-images.githubusercontent.com/7997618/35738996-56de08aa-07fe-11e8-9982-7f38a1c1e917.png)

JSON payloads are editable. I'm in the process of adding retry/resolve
functionality to it too, similar to what Wombat had.

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
