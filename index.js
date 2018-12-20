'use strict';

const AWS = require('aws-sdk');
const elasticsearch = require('elasticsearch');
const httpAWSES = require('http-aws-es');
const fs = require('fs');
const dataset = JSON.parse(fs.readFileSync('data/data.json', 'utf8'));

console.log(`Connecting to ElasticSearch`);

const options = {
	host: process.env.ES_ENDPOINT,
};

const region = options.region || process.env.AWS_REGION || 'us-east-1';
const config = Object.assign(
	{},
	options,
	{
		connectionClass: httpAWSES,
		awsConfig: new AWS.Config({
			region,
			credentials: options.credentials
		})
	}
);


var client = new elasticsearch.Client(config);

client.cluster.health({}, function(err, resp, status) {
  console.log('-- Client Health --', resp);
});

const response = client.indices.create({
  index: 'population',
}, function(err, resp, status) {
  if(err) {
    console.log(err);
  }
  else {
    console.log("create",resp);
  }
});

var bulk = [];
for(var current in dataset) {
  bulk.push({ index: {_index: 'population', _type: 'countries', _id: current } },
      {
        'females': dataset[current].females,
        'age': dataset[current].age,
        'males': dataset[current].males,
        'year': dataset[current].year,
        'total': dataset[current].total,
        'country': dataset[current].country,
      })
}

client.bulk({
  index: 'population',
  type: 'countries',
  body: bulk,
},function(err, resp, status) {
    console.log(resp);
});
