# fluent-plugin-json-input
Fluentd input plugin to read json blocks with stacktraces from a tcp stream. Native tcp plugin expects a delimeter to be defined, if you have stack traces with multiple lines, it is not going to read the input chunk properly. But with this input plugin you can capture the exact json block.
