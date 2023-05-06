import 'package:flutter/material.dart';

class EventCategory{
  final String name;
  final Image icon;

  EventCategory(this.name, this.icon);

  static List<EventCategory> getEventCategories(){
    List<EventCategory> categories = [
      EventCategory('Hang out', Image.asset('assets/icons/celebration_icon.png')),
      EventCategory('Party', Image.asset('assets/icons/nightlife.png')),
      EventCategory('Chill', Image.asset('assets/icons/chill.png')),
      EventCategory('Entertainment', Image.asset('assets/icons/movie_filter.png')),
      EventCategory('Sports', Image.asset('assets/icons/sports.png')),
      EventCategory('Art', Image.asset('assets/icons/piano.png')),
      EventCategory('Nature', Image.asset('assets/icons/waves.png')),
      EventCategory('Intellectual', Image.asset('assets/icons/mindfulness_icon.png')),
    ];
    return categories;
  }

  static EventCategory getCategoryById(int id){
    return getEventCategories()[id];
  }
}