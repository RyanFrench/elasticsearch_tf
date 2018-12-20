output "kibana" {
  value = "${aws_elasticsearch_domain.elasticsearch.kibana_endpoint}"
}

output "elasticsearch" {
  value = "${aws_elasticsearch_domain.elasticsearch.endpoint}"
}
