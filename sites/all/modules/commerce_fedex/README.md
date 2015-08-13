Commerce FedEx
--------------

This module currently supports FedEx Express and FedEx Ground / Home Delivery.


Customizing Packing Methods
===========================

By default, this module attempts to put every item in the cart that has 
dimensions and weight into boxes that match the default selected box size and
up to the maximum weight. For example, if you have 4 items that are 5x5x5 and have a weight of 4 lbs each, then the default configuration will put all 4 items into a single 20x20x20 box and assign it a weight of 16 pounds.

If you need to modify the way that FedEx packages up the order, you can use

    HOOK_commerce_fedex_rate_request_alter(&$request, $order);

to do so. This will allow you to iterate over the order line items and package
up the order as you'd like.
