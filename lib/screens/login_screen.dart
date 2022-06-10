import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otp_sender/screens/home_screen.dart';


enum MobileVerificationState {
SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE
}
String?verificationId;
FirebaseAuth _auth=FirebaseAuth.instance;
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  MobileVerificationState currentState=MobileVerificationState.SHOW_MOBILE_FORM_STATE;
  final phoneController=TextEditingController();
  final otpController=TextEditingController();
  bool showLoading=false;


  void signInwithPhoneAuthCrendential(AuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading=true;
    });
     try {
       final authCredential=await _auth.signInWithCredential(phoneAuthCredential);
       setState(() {
         showLoading=false;
       });

       if(authCredential?.user!=null)
         {
           Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
         }
     } on FirebaseAuthException catch (e) {
       // TODO
       setState(() {
         showLoading=false;
       });
     }
  }
  getMobileFormWidget(context)
  {
    return Column(
     children: [
       Spacer(),
       TextField(
         controller: phoneController,
         decoration: InputDecoration(
           hintText: "Enter Phone number "
         ),
       ),

       FlatButton(onPressed:()async{
         setState(() {
           showLoading=true;
         });
         await _auth.verifyPhoneNumber(
           phoneNumber: phoneController.text,
           verificationCompleted: (PhoneAuthCredential) async{
             setState(() {
               showLoading=false;
             });
             //signInwithPhoneAuthCrendential(phoneAuthCredential);
           },
           verificationFailed: (verificationFailed)async{
             _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(verificationFailed.message.toString())));
             setState(() {
               showLoading=false;
             });
           },
           codeSent: (verifyId,resendingToken)async{
             setState(() {
               currentState=MobileVerificationState.SHOW_OTP_FORM_STATE;
               showLoading=false;
                verificationId=verifyId;
             });
           },
           codeAutoRetrievalTimeout: (verificationId)async{

           },
         );
       }, child: Text("Send"),color: Colors.blueAccent,textColor: Colors.white,),
       Spacer(),
     ],
    );
  }
  getOtpFormWidget(context)
  {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: otpController,
          decoration: InputDecoration(
              hintText: "Enter OTP "
          ),
        ),

        FlatButton(onPressed: ()async{
          final phoneAuthCredential=PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpController.text);
          signInwithPhoneAuthCrendential(phoneAuthCredential);
        }, child: Text("Verify"),color: Colors.blueAccent,textColor: Colors.white,),
        Spacer(),
      ],
    );
  }

  final GlobalKey<ScaffoldState>_scaffoldKey=GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: showLoading ? Center(child: CircularProgressIndicator(),):currentState==MobileVerificationState.SHOW_MOBILE_FORM_STATE? getMobileFormWidget(context):
        getOtpFormWidget(context),
        padding: EdgeInsets.all(16),
      )
    );
  }
}

