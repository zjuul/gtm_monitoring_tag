___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.



___INFO___

{
  "displayName": "GTM Monitoring in Google Analytics",
  "categories": ["TAG_MANAGEMENT", "UTILITY", "ANALYTICS"],
  "description": "A template for setting up tag monitoring in Google Tag Manager and store result in a Google Analytics property (enhanced ecommerce)",
  "__wm": "VGVtcGxhdGUtQXV0aG9yX0dvb2dsZS1UYWctTWFuYWdlci1Nb25pdG9yLVNpbW8tQWhhdmE=",
  "securityGroups": [],
  "id": "cvt_temp_public_id",
  "type": "TAG",
  "version": 1,
  "brand": {
    "displayName": "",
    "id": "brand_dummy"
  },
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "help": "Use the code, including the UA- bit.",
    "alwaysInSummary": true,
    "valueValidators": [
      {
        "type": "GA_TRACKING_ID",
        "errorMessage": "The field must be a valid UA property string (UA-12345-6)"
      }
    ],
    "displayName": "Analytics Property to send to",
    "simpleValueType": true,
    "name": "uaCode",
    "type": "TEXT",
    "valueHint": "UA-123213-1"
  },
  {
    "displayName": "Advanced Setup and Customisation",
    "name": "advanced",
    "groupStyle": "ZIPPY_CLOSED",
    "type": "GROUP",
    "subParams": [
      {
        "help": "If left blank, the Event Label used to store the hit is the timestamp. You can use something custom here, like the contents of the dataLayer.",
        "displayName": "Event Label to use",
        "simpleValueType": true,
        "name": "customEventLabel",
        "type": "TEXT"
      },
      {
        "help": "If left blank, a timestamp + random number is used. \nYou can use a variable with the client ID of the current visitor (beware of the 500 hits limit!), or your own random number.",
        "alwaysInSummary": true,
        "displayName": "Client ID to use",
        "simpleValueType": true,
        "name": "clientId",
        "type": "TEXT"
      },
      {
        "help": "If you select <strong>No</strong>, details of all the tags that fired for any given hit are sent in a single GET request. If you select <strong>Yes</strong>, you can choose the maximum number of tags per request, and the tag will automatically send multiple requests if necessary.",
        "displayName": "Batch hits",
        "simpleValueType": true,
        "name": "batchHits",
        "type": "RADIO",
        "radioItems": [
          {
            "displayValue": "No",
            "value": "no"
          },
          {
            "displayValue": "Yes",
            "help": "",
            "value": "yes",
            "subParams": [
              {
                "help": "Enter the maximum number of tags per request that will be dispatched to the endpoint. If necessary, multiple requests will be made.",
                "valueValidators": [
                  {
                    "type": "POSITIVE_NUMBER"
                  }
                ],
                "displayName": "Maximum number of tags per request",
                "defaultValue": 10,
                "simpleValueType": true,
                "name": "maxTags",
                "type": "TEXT"
              }
            ]
          }
        ]
      }
    ]
  }
]


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "event"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_pixel",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://www.google-analytics.com/collect*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_metadata",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_url",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Require the necessary APIs
const addEventCallback = require('addEventCallback');
const readFromDataLayer = require('copyFromDataLayer');
const sendPixel = require('sendPixel');
const getTimestamp = require('getTimestamp');
const getUrl = require('getUrl');
const encodeUriComponent = require('encodeUriComponent');
const generateRandom = require('generateRandom');

// Get the dataLayer event that triggered the tag
const event = readFromDataLayer('event');

const eventTimestamp = getTimestamp(); // used for eventlabel, transaction id, anti-cache
const uaCode = data.uaCode;
const batchHits = data.batchHits === 'yes';
const maxTags = data.maxTags;
const hostName = getUrl('host'); // used for product category, affiliation
const pathName = encodeUriComponent(getUrl('path'));
const fullHost = getUrl(); // location field
const eventLabel = data.customEventLabel ? data.customEventLabel : eventTimestamp;
const clientId = data.clientId ? data.clientId : eventTimestamp +' '+ generateRandom(1,999);

// measurement protocol prep
let endPoint = 'https://www.google-analytics.com/collect?z=' + eventTimestamp +
    '&v=1' +
    '&tid=' + uaCode +
    '&cid=' + clientId +
    '&t=event' +
    '&dp=' + pathName +
    '&dh=' + hostName +
    '&dl=' + encodeUriComponent(fullHost) +
    '&pa=purchase' +
    '&ta=' + hostName + // affiliation
    '&ec=gtm_monitor'
;

let eventValue = 0;

// Utility for splitting an array into multiple arrays of given size
const splitToBatches = (arr, size) => {
  const newArr = [];
  for (let i = 0, len = arr.length; i < len; i += size) {
    newArr.push(arr.slice(i, i + size));
  }
  return newArr;
};

// The addEventCallback gets two arguments: container ID and a data object with an array of tags that fired
addEventCallback((ctid, eventData) => {

  // Filter out the monitoring tag itself
  const tags = eventData.tags.filter(t => t.exclude !== 'true');
  
  // If batching is enabled, split the tags into batches of the given size
  const batches = batchHits ? splitToBatches(tags, maxTags) : [tags];
  
  // For each batch, build a payload and dispatch to the endpoint as a GET request
  batches.forEach(tags => {
    let payload = '&ea=' + encodeUriComponent(event) + '&ti=' + eventTimestamp +
        '&el=' + eventLabel;
    tags.forEach((tag, idx) => {
      eventValue = eventValue + 1;
      const tagPrefix = '&pr' + (idx + 1);
      
      let tagName = tag.name ? tag.name : 'unnamed tag with ID: ' + tag.id;
      
      payload +=
        tagPrefix + 'id=' + tag.id +                        // SKU
        tagPrefix + 'nm=' + encodeUriComponent(tagName) +   // product name
        tagPrefix + 'va=' + tag.status +                    // variant
        tagPrefix + 'ca=' + event +                         // category
        tagPrefix + 'br=' + pathName +                      // brand
        tagPrefix + 'qt=1' + 								// quantity = 1
        tagPrefix + 'pr=' + tag.executionTime + ".00";      // time = money
    });
    payload += '&tr=' + eventValue + ".00" +   // trans.revenue = nr of prods
    	 '&ev=' + eventValue;                  // event value = nr of products
    sendPixel(endPoint + payload, null, null);
  });
});

// After adding the callback, signal tag completion
data.gtmOnSuccess();


___NOTES___

Created on 11/07/2019, 09:11:59
