import 'package:flutter/material.dart';


class SliderModel{

  String imageAssetPath;
  String title;
  String desc;

  SliderModel({this.imageAssetPath,this.title,this.desc});

  void setImageAssetPath(String getImageAssetPath){
    imageAssetPath = getImageAssetPath;
  }

  void setTitle(String getTitle){
    title = getTitle;
  }

  void setDesc(String getDesc){
    desc = getDesc;
  }

  String getImageAssetPath(){
    return imageAssetPath;
  }

  String getTitle(){
    return title;
  }

  String getDesc(){
    return desc;
  }

}


List<SliderModel> getSlides(){

  List<SliderModel> slides = new List<SliderModel>();
  SliderModel sliderModel = new SliderModel();

  //1
  sliderModel.setDesc("Discover Restaurants offering the best fast food near you on Nearby");
  sliderModel.setTitle("Search");
  sliderModel.setImageAssetPath("assets/images/burger.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  //2
  sliderModel.setDesc("Locate any Hospitals near your Location");
  sliderModel.setTitle("Locate");
  sliderModel.setImageAssetPath("assets/images/location.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  //3
  sliderModel.setDesc("Explore restaurants and many more things close to you");
  sliderModel.setTitle("Explore");
  sliderModel.setImageAssetPath("assets/images/scooter.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  return slides;
}