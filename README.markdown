Lighthouse API
--------------

The official Ruby library for interacting with the [Lighthouse REST API](http://lighthouseapp.com/api). 

### Documentation & Requirements
* ActiveResource 
* ActiveSupport

Check out lib/lighthouse.rb for examples and documentation.


### Using The Lighthouse Console

The Lighthouse library comes with a convenient console for testing and quick commands 
(or whatever else you want to use it for).

From /lib:

    irb -r lighthouse/console
    Lighthouse.account = "activereload"

    #### You can use `authenticate` OR `token`
    Lighthouse.authenticate('username', 'password')
    #Lighthouse.token = 'YOUR_TOKEN'
    
    Project.find(:all)
