import 'package:flutter/material.dart';

class EventCategory{
  final String name;
  final Image icon;
  final Color color;

  EventCategory(this.name, this.icon, this.color);

  static List<EventCategory> getEventCategories(){
    List<EventCategory> categories = [
      EventCategory('Hang out', Image.asset('assets/icons/celebration_icon.png'), Colors.white),
      EventCategory('Party', Image.asset('assets/icons/nightlife.png'), Colors.white),
      EventCategory('Chill', Image.asset('assets/icons/chill.png'), Colors.white),
      EventCategory('Entertainment', Image.asset('assets/icons/movie_filter.png'), Colors.white),
      EventCategory('Sports', Image.asset('assets/icons/sports.png'), Colors.white),
      EventCategory('Art', Image.asset('assets/icons/piano.png'), Colors.white),
      EventCategory('Nature', Image.asset('assets/icons/waves.png'), Colors.white),
      EventCategory('Intellectual', Image.asset('assets/icons/mindfulness_icon.png'), Colors.white),
    ];
    return categories;
  }

  static EventCategory getCategoryById(int id){
    return getEventCategories()[id];
  }
}