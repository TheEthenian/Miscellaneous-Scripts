import os
import wave 
import json
from piper import PiperVoice
from piper import PiperConfig
from PyPDF2 import PdfReader


# file directories listing
voice_location = "/home/ethenian/piper_voices/british-cori-high/en_GB-cori-high.onnx"
json_location = "/home/ethenian/piper_voices/british-cori-high/en_GB-cori-high.onnx.json"
synthesised_dictation_storage = "/home/ethenian/Synthesised_voice_pdf_text_audiofiles"


# check if directories in path_to place_synthesised_audio exists if not make it
def check_dir_existance_create(path_to_file):
    directory_path = os.path.dirname(path_to_file)
    
    if directory_path:
        os.makedirs(directory_path, exist_ok=True)
        print(f"Made sure {directory_path} exists")
    else:
        print("Nothing to see here")


# converts pdf to text and has various customs such as starting page, ending page for selective text output
def pdf_convertion_to_text(file_path):
    start_page = input('Starting page: ')
    end_page = input('Ending page: ')
    current_page = 0
    accumulated_converted_pdf_text = ""
    
    reader = PdfReader('/home/ethenian/'+ file_path)
    while current_page < int(end_page):
        if current_page == 0:
            current_page = int(start_page)
    
        page = reader.pages[current_page]
        accumulated_converted_pdf_text += page.extract_text()
        current_page += 1
    
    print(f"Finished conversion of {file_path} to text")
    return accumulated_converted_pdf_text 


# Voice synthesis of presented input as text
def voice_synthesis(text,audio_name,group_name):
    synthesised_audio_name = f"{audio_name}.wav"
    path_to_place_synthesised_audio = f"{synthesised_dictation_storage}/{group_name}/{synthesised_audio_name}"

    # acertain the existance of the file path directories
    check_dir_existance_create(path_to_place_synthesised_audio)

    #Load the downloaded voice from its location
    try:
        voice = PiperVoice.load(voice_location)
    except Exception as e:
        print(f"Error loading Piper voice model from : {voice_location} : {e}")
        return 

    #customize the voice_synthesized
    #with open(json_location,"r",encoding="utf-8") as config_file:
    #    config_dict = json.load(config_file)
    #    config = PiperConfig.from_dict(config_dict)


    # Write the synthesized text to audio
    try:
        with wave.open(path_to_place_synthesised_audio,"wb") as wavefile:
            voice.synthesize_wav(text, wavefile) #syn_config=config
            print("Speech synthesised")
    except Exception as e:
        print(f"Error synthesising speech or writing to WAV file: {e}")




# Main function orchestrating everything
def main():

    # various inputs for customized synthesised voice
    file_type = input("Input Propensity: Enter 1 => pdf file, Enter 2 => text file, Enter 3 => write text: ")
    audio_name = input("Name Audio File: ")
    group_placement = input("Destination Group Directory of Audio File: ")
    #voice_speed = input("What speed would you like cori to have less is more: ")

    try:


        #PDF file to speech
        if int(file_type) == 1:

            file = input("File Path continue from this /home/ethenian/: ")
            text_extracted = pdf_convertion_to_text(file)
            voice_synthesis(text_extracted,audio_name,group_placement)


        #Text file to speech
        if int(file_type) == 2:

            file = input("File Path continue from this /home/ethenian/: ")
            path_to_text_file = f"/home/ethenian/{file}"

            # Write the synthesized text to audio
            try:

                with open(path_to_text_file, "r" ,encoding='utf-8') as file_txt:
                    text_content = file_txt.read()
                    voice_synthesis(text_content,audio_name,group_placement)

            except Exception as e:
                print(f"This went wrong with opening text_file: {e}")
                

        #Typed text to speech
        if int(file_type) == 3:
            typed_text = input("Type Text for Cori to voice synthesize: ")
            voice_synthesis(typed_text,audio_name,group_placement)


    except Exception as e:
        print(f"Error in main component : {e}")




if __name__ == "__main__":
    main()

