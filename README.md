This GTM template tag will Debug and Monitor your Google Tag Manager implementation. Monitoring data will be stored in a Google Analytics property, using enhanced ecommerce tracking.

https://stuifbergen.com/2019/08/gtm-monitoring-in-google-analytics/


Details of the information sent:

Every monitoring hit that is sent, is of type event, with an added ecommerce action of type transaction
* Event Category: gtm_monitor
* Event Action: the GTM event name
* Event Label: configurable (default is a timestamp)
* Event Value: the number of tags sent in this monitoring hit
Hostname and Page Path are sent
* Every Tag that is fired and monitored is sent as a product
* Product Name: GTM tag name that fires (or the ID, if no name is set)
* Product SKU: GTM tag ID
* Product Category: the GTM event name
* Product Variant: the tag firing status (success or failure)
* Product Brand: the path name
* Product Price: the tag execution time
Finally, the transaction has the following properties
* Transaction ID: the timestamp
* Store affiliation: the hostname
* Transaction revenue: the number of tags sent in this monitoring hit

As a bonus, the client id that is used, is configurable as well. The default is to use a timestamp (with a random number attached), but if you have a variable configured with the actual client ID in it, you can use this as well.
Note that for every client ID, there is a limit of 500 hits in Google Analytics, so this setup will not work for sites that fire a decent amount of tags (but remember you can always store the client id in the Event Label.

