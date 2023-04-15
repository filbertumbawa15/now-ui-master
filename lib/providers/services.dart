// import 'dart:html';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:now_ui_flutter/api/s&k/pdf_sk_api.dart';
import 'package:now_ui_flutter/models/dart_models.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:now_ui_flutter/globals.dart' as globals;

part 'master_provider.dart';

String baseUrl = 'https://tasmedan.dynu.com:8888/apicrud/index.php/api/';
