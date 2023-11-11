import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key});

  _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: '218079354@mycput.ac.za',
    );
    if (await canLaunchUrl(emailUri.toString() as Uri)) {
      await launchUrl(emailUri.toString() as Uri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  _launchGithub() async {
    const String githubUrl = 'https://github.com/MasKash3?tab=repositories';
    if (await canLaunchUrl(githubUrl as Uri)) {
      await launchUrl(githubUrl as Uri);
    } else {
      throw 'Could not launch $githubUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iReception'),
        toolbarHeight: 70,
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                "This is a software written for the purpose of the Engineering Project course in Postgraduate Diploma \n"
                "at the Cape Peninsula University of Technology.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _launchEmail,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email,
                    color: Colors.black,
                    size: 24,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Contact us',
                    style: TextStyle(
                      color: Colors.blue, // Make the email text blue
                      decoration: TextDecoration.underline, // Add underline
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _launchGithub,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/ic_github.png'),
                    width: 24,
                    color: Colors.black,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Github',
                    style: TextStyle(
                      color: Colors.blue, // Make the Github link text blue
                      decoration: TextDecoration.underline, // Add underline
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
