import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:matter/effects/typewriting.dart';


import '../controllers/debate_logic.dart';

class DualAI extends StatefulWidget {
  const DualAI({super.key});

  @override
  State<DualAI> createState() => _DualAIState();
}

class _DualAIState extends State<DualAI> with SingleTickerProviderStateMixin {
  final DebateController controller = Get.find();
  ScrollController scrollcontroller = ScrollController();
  ScrollController scrollcontroller2 = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
      lowerBound: 0,
      upperBound: 1,
    )..addListener(() {
      setState(() {});
    });
  }

  void _scrollToBottom1() {
    scrollcontroller.animateTo(
      scrollcontroller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToBottom2() {
    scrollcontroller2.animateTo(
      scrollcontroller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeInOut,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(right: 20, left: 20, top: 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Obx(() => Container(
                  height: 230,
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.deepPurple.shade100,
                        Colors.deepPurple.shade200,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child:  SingleChildScrollView(
                    controller: scrollcontroller2,
                    child: TypewriterText(
                      text: controller.ai2Response.value,
                      duration: const Duration(milliseconds: 50),
                      onCharacterTyped: _scrollToBottom2,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ),
                )),
            
                // AI 2 Animation and Status
                Obx(() => Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        controller.isDebating.value
                            ? (controller.isAI1Speaking.value ? "Listening" : "Speaking")
                            : '',
                        style: TextStyle(fontSize: 16, color: Colors.green[700]),
                      ),
                      Lottie.asset(
                        "assets/json/ai2.json",
                        controller: controller.animationController,
                        height: 80,
                        width: 100,
                      ),
                    ],
                  ),
                )),
            
                // Center Button
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (!controller.isDebating.value) {
                        controller.startDebate();
                      } else {
                        controller.resetDebate();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Lottie.asset(
                          "assets/json/center.json",
                          controller: controller.animationController,
                          height: 180,
                          width: 180,
                          fit: BoxFit.fill,
                        ),
                        Obx(() => AnimatedOpacity(
                          opacity: controller.isDebating.value ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: const Text(
                            'Start',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
            
                // AI 1 Response Container
                Obx(() => Container(
                  height: 230,
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.deepPurple.shade50,
                        Colors.deepPurple.shade100,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollcontroller,
                    child: TypewriterText(
                      text: controller.ai1Response.value,
                      duration: const Duration(milliseconds: 50),
                      onCharacterTyped: _scrollToBottom1,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ),
                )),
            
                // AI 1 Animation and Status
                Obx(() => Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Lottie.asset(
                        "assets/json/ai1.json",
                        controller: controller.animationController,
                        height: 100,
                        width: 115,
                      ),
                      Text(
                        controller.isDebating.value
                            ? (!controller.isAI1Speaking.value ? "Listening" : "Speaking")
                            : '',
                        style: TextStyle(fontSize: 16, color: Colors.green[700]),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.animationController?.dispose();
    super.dispose();
  }
}