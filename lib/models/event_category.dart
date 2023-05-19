class EventCategory{
  final int id;
  final String name;

  EventCategory(this.id, this.name);

  static List<EventCategory> getEventCategories(){
    List<EventCategory> categories = [
      EventCategory(0, 'Hang out'),
      EventCategory(1, 'Party'),
      EventCategory(2, 'Chill'),
      EventCategory(3, 'Entertainment'),
      EventCategory(4, 'Sports'),
      EventCategory(5, 'Art'),
      EventCategory(6, 'Nature'),
      EventCategory(7, 'Intellectual'),
    ];
    return categories;
  }

  static EventCategory getCategoryById(int id){
    return getEventCategories()[id];
  }
}