const String apiBaseUrl = 'http://localhost:8000/api';

const int apiTimeoutSeconds = 30;

const int apiMaxRetries = 3;

const Map<String, String> apiDefaultHeaders = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
};