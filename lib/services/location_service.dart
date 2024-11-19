import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

// class LocationService{
//   //static const url = 'http://127.0.0.1:8000/api/';
//   static const url = 'http://192.168.56.1:8000/api/';
//   Future getLocations() async {
//     var response = await http.get(Uri.parse(url+'locations'));
//     if(response.statusCode == 200){
//       var jsonResponse = convert.jsonDecode(response.body);
//       print(jsonResponse);
//     }else{
//       return 'error';
//     }
//   }
// }

class LocationService {  
  //static const url = 'http://192.168.0.6:8000/api/';
  static const url = 'https://c111-131-0-196-229.ngrok-free.app/api/';

  // Future<List<Map<String, dynamic>>> getLocations() async {
  //   try {
  //     var response = await http.get(Uri.parse(url + 'locations'));
      
  //     if (response.statusCode == 200) {
  //       var jsonResponse = convert.jsonDecode(response.body);
        
  //       if (jsonResponse is List) {
  //         return List<Map<String, dynamic>>.from(jsonResponse);
  //       } else {
  //         print('Error: Estructura JSON inesperada');
  //         return [];  // Retorna una lista vacía en caso de error de estructura
  //       }
  //     } else {
  //       print('Request failed with status: ${response.statusCode}');
  //       return [];  // Retorna una lista vacía si la solicitud falla
  //     }
  //   } catch (e) {
  //     print('Error al procesar la respuesta JSON: $e');
  //     return [];  // Retorna una lista vacía en caso de excepción
  //   }
  // }

    Future getLocations() async {
    var response = await http.get(Uri.parse(url+'locations'));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse;
    } else {
      return 'Error de conexion';
    }
  }

}