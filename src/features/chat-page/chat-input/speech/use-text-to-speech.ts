import { showError } from "@/features/globals/global-message-store";
import {
  AudioConfig,
  ResultReason,
  SpeakerAudioDestination,
  SpeechConfig,
  SpeechSynthesizer,
} from "microsoft-cognitiveservices-speech-sdk";
import { proxy, useSnapshot } from "valtio";
import { GetSpeechToken, GetSpeechVoice } from "./speech-service";
import { speechToTextStore } from "./use-speech-to-text";

let player: SpeakerAudioDestination | undefined = undefined;

class TextToSpeech {
  public isPlaying: boolean = false;

  public stopPlaying() {
    this.isPlaying = false;
    if (player) {
      player.pause();
    }
  }

  public async textToSpeech(textToSpeak: string) {
    if (this.isPlaying) {
      this.stopPlaying();
    }

    const tokenObj = await GetSpeechToken();

    if (tokenObj.error) {
      showError(tokenObj.errorMessage);
      return;
    }

    const speechConfig = SpeechConfig.fromAuthorizationToken(
      tokenObj.token,
      tokenObj.region
    );

    const voiceObj = await GetSpeechVoice();
    if (voiceObj.error) {
      showError(voiceObj.errorMessage);
      return;
    }

    speechConfig.speechSynthesisVoiceName = voiceObj.voice;

    player = new SpeakerAudioDestination();

    var audioConfig = AudioConfig.fromSpeakerOutput(player);
    let synthesizer = new SpeechSynthesizer(speechConfig, audioConfig);

    player.onAudioEnd = () => {
      this.isPlaying = false;
    };

    synthesizer.speakTextAsync(
      textToSpeak,
      (result) => {
        if (result.reason === ResultReason.SynthesizingAudioCompleted) {
          this.isPlaying = true;
        } else {
          showError(result.errorDetails);
          this.isPlaying = false;
        }
        synthesizer.close();
      },
      function (err) {
        console.error("err - " + err);
        synthesizer.close();
      }
    );
  }

  public speak(value: string) {
    if (speechToTextStore.userDidUseMicrophone()) {
      textToSpeechStore.textToSpeech(value);
      speechToTextStore.resetMicrophoneUsed();
    }
  }
}

export const textToSpeechStore = proxy(new TextToSpeech());

export const useTextToSpeech = () => {
  return useSnapshot(textToSpeechStore);
};
