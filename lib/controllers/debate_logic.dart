import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:matter/const.dart';
import 'package:matter/controllers/popup_styles.dart';
import 'package:matter/pages/home_page.dart';
import 'package:matter/prompts/prompts.dart';

class DebateController extends GetxController {

  final topicController = TextEditingController();


  final isDebating = false.obs;
  final isSpeaking = false.obs;
  final isAI1Speaking = true.obs;
  final ai1Response = ''.obs;
  final ai2Response = ''.obs;

  // Voice
  FlutterTts? flutterTts;
  final isTTSInitialized = false.obs;

  // AI Models
  late GenerativeModel model1;
  late GenerativeModel model2;
  late GenerativeModel model3;
  ChatSession? chatSession1;
  ChatSession? chatSession2;


  AnimationController? animationController;

  @override
  void onInit() {
    super.onInit();
    initializeTTS();
    initializeAI();
  }

  void showHarmfulContentDialog() {
    showCustomDialog(title: "'Harmful Content Detected'", middleText: "'Please enter a meaningful topic'");
  }

  Future<void> initializeTTS() async {
    try {
      flutterTts = FlutterTts();

      var voices = await flutterTts!.getVoices;
      print('Available Android voices: $voices');

      await flutterTts!.setLanguage("en-US");
      flutterTts!.setCompletionHandler(() {
        isSpeaking.value = false;
      });

      isTTSInitialized.value = true;
    } catch (e) {

      isTTSInitialized.value = false;
    }
  }

  void initializeAI() {

     model3 = GenerativeModel(
      model: 'gemini-pro',
      apiKey: GEMINI_API_KEY,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
      ],
    );

    // Initialize AI Model 1
    model1 = GenerativeModel(
      model: 'gemini-pro',
      apiKey: GEMINI_API_KEY,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
      ],
    );

    // Initialize AI Model 2
    model2 = GenerativeModel(
      model: 'gemini-pro',
      apiKey: GEMINI_API_KEY,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
      ],
    );
  }

  void showInvalidTopicDialog(String reason) {
    showCustomDialog(title: "Invalid Topic", middleText: reason);
  }

  Future<bool> validateTopic(String topic) async {

    try {

      final chat = model2.startChat();

      final validationResponse = await chat.sendMessage(Content.text(
      topicValidationPrompt(topic)));


      final validation = validationResponse.text?.trim().toUpperCase();
      print(validation);

      switch (validation) {
        case 'VALID':
          return true;
        case 'INVALID':
          showInvalidTopicDialog('Please enter a meaningful topic');
          return false;
        default:
          showInvalidTopicDialog('Please enter a clear, debatable topic.');
          return false;
      }
    } catch (e) {
      print('Validation error: $e');
      showInvalidTopicDialog('Please enter a clear, debatable topic.');
      return false;
    }
  }


  void initializeDebate() {
    final topic = topicController.text;

    // Initialize Chat Session 1
    chatSession1 = model1.startChat(history: [
      Content.text(forSessionPrompt(topic))
    ]);

    // Initialize Chat Session 2
    chatSession2 = model2.startChat(history: [
      Content.text(skepticPrompt(topic))
    ]);}

  Future<void> speak(String text, bool isAI1) async {
    if (!isTTSInitialized.value || flutterTts == null) return;

    try {
      if (isSpeaking.value) {
        await flutterTts?.stop();
      }

      if (isAI1) {
        // Female voice settings
        await flutterTts!.setVoice({
          "name": "en-us-x-sfg-network",
          "locale": "en-US",
          "quality": "Very High",
        });
        await flutterTts!.setPitch(1.3);
        await flutterTts!.setVolume(1.0);
        await flutterTts!.setSpeechRate(0.5);
      } else {
        // Male voice settings
        await flutterTts!.setVoice({
          "name": "en-us-x-iam-network",
          "locale": "en-US",
          "quality": "Very High",
        });
        await flutterTts!.setPitch(0.6);
        await flutterTts!.setVolume(1.0);
        await flutterTts!.setSpeechRate(0.5);
      }

      isSpeaking.value = true;
      await flutterTts?.speak(text);
    } catch (e) {
      print('Speech failed: $e');
      isSpeaking.value = false;
    }
  }

  Future<void> runDebate() async {
    if (!isDebating.value) return;

    try {
      // AI-1 opening argument
      GenerateContentResponse? response1;
      try {
        response1 = await chatSession1?.sendMessage(
          Content.text("Present your opening argument on the debate topic."),
        );
      } on GenerativeAIException catch (e) {
        print('Generative AI Exception: ${e.message}');
        stopDebate();
        showHarmfulContentDialog();
        return;
      }

      if (!isDebating.value) return;

      ai1Response.value = response1?.text ?? '';
      isAI1Speaking.value = true;
      await speak(ai1Response.value, true);


      while (isDebating.value) {
        await waitForSpeechCompletion();

        // AI-2's response
        GenerateContentResponse? response2;
        try {
          isAI1Speaking.value = false;
          response2 = await chatSession2?.sendMessage(
            Content.text("Respond to this argument: ${ai1Response.value}"),
          );
        } on GenerativeAIException catch (e) {
          print('Generative AI Exception: ${e.message}');
          stopDebate();
          showHarmfulContentDialog();
          return;
        }

        if (!isDebating.value) break;

        ai2Response.value = response2?.text ?? '';
        await speak(ai2Response.value, false);

        await waitForSpeechCompletion();

        // AI-1's counter-response
        GenerateContentResponse? nextResponse1;
        try {
          isAI1Speaking.value = true;
          nextResponse1 = await chatSession1?.sendMessage(
            Content.text("Counter this point: ${ai2Response.value}"),
          );
        } on GenerativeAIException catch (e) {
          print('Generative AI Exception: ${e.message}');
          stopDebate();
          showHarmfulContentDialog();
          return;
        }

        if (!isDebating.value) break;

        ai1Response.value = nextResponse1?.text ?? '';
        await speak(ai1Response.value, true);
      }
    } catch (e) {
      print('Error in debate: $e');
      stopDebate();

      // Safety
      showCustomDialog(title: "'Harmful Content Detected'", middleText: "'Please enter a meaningful topic'");
    }
  }

  Future<void> waitForSpeechCompletion() async {
    while (isSpeaking.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> startDebate() async {
    final topic = topicController.text.trim();

    // Validate topic before starting debate
    final isValid = await validateTopic(topic);

    if (!isValid) {
      return;
    }

    isDebating.value = true;
    animationController?.repeat();
    initializeDebate();
    runDebate();
  }

  void stopDebate() {
    isDebating.value = false;
    animationController?.reset();
    isSpeaking.value = false;
    flutterTts?.stop();
    ai1Response.value = '';
    ai2Response.value = '';
  }

  void resetDebate() {
    stopDebate();
    topicController.clear();
    Get.back();
  }

  @override
  void onClose() {
    flutterTts?.stop();
    topicController.dispose();
    animationController?.dispose();
    super.onClose();
  }
}