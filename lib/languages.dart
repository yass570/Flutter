

class LanguagesPages {

  String getWord(String word, lng){
    if(enWords.contains(word)){

      if(lng=="Ar"){
        return arWords[enWords.indexOf(word)];
      }else if(lng=="Fr"){
        return frWords[enWords.indexOf(word)];
      }else {
        return word;
      }

    }else{
      return word;
    }

  }

  List<String> enWords = ["Sign In","Sign Up","Forgot Password","Email","Incorrect Email or Password","Incorrect Email address","Password do not match","Password length min 7 character","Unknown Error","Check your email address, and follow the link to reset your password","Email Address","Password","Confirm Password","Forgot Password","Reset PassWord","Code","Validate","Profile Picture","Visit the Website",];
  List<String> frWords = ["S identifier","S inscrire","Mot de passe oublié","Email","Email ou mot de passe incorrect","Adresse e-mail incorrecte","Le mot de passe ne correspond pas","Longueur du mot de passe min 7 caractères","Erreur inconnue","Vérifiez votre adresse e-mail et suivez le lien pour réinitialiser votre mot de passe","Adresse e-mail","Mot de passe","Confirmez le mot de passe","Mot de passe oublié","Réinitialiser le mot de passe","Code","Valider","Image de profil","Visitez le site Web",];
  List<String> arWords = ["تسجيل","اشتراك","نسيت كلمة السر"," البريد ","بريد أو كلمة مرورغير صحيحة","البريد الألكتروني غير صحيح","كلمة السر غير مطابقة","طول كلمة المرور 7 أحرف كحد أدنى","خطأ غير معروف","تحقق من عنوان بريدك الإلكتروني ، واتبع الرابط لإعادة تعيين كلمة المرور الخاصة بك","البريد الإلكتروني","كلمه السر","تأكيد كلمة المرور","نسيت كلمة السر","إعادة تعيين كلمة المرور","الرمز","تحقق","الصوره الشخصيه","قم بزيارة الموقع",];

}