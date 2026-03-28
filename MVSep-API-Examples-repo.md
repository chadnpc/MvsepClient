This file is a merged representation of the entire "github.com/ZFTurbo/MVSep-API-Examples" codebase, combined into a single markdown file.

# File Summary

## Purpose
This file contains a packed representation of the entire repository's contents.
It is designed to be easily consumable by AI systems for analysis and code review.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Security check has been disabled - content may contain sensitive information
- Files are sorted by Git change count (files with more changes are at the bottom)

# Files

## File: python_example1/api_example.py
````python
import os
import sys
import json
import requests
import argparse
from typing import Union


def create_separation(args):
    files = {
        'audiofile': open(args.input, 'rb'),
        'api_token': (None, args.token),
        'sep_type': (None, args.sep_type),
        'add_opt1': (None, args.add_opt1),
        'add_opt2': (None, args.add_opt2),
        'output_format': (None, '1'),
        'is_demo': (None, '0'),
    }

    response = requests.post('https://mvsep.com/api/separation/create', files=files)
    string_response = response.content.decode('utf-8')
    parsed_json = json.loads(string_response)
    hash = parsed_json["data"]["hash"]

    return hash, response.status_code


def download_file(url, filename, save_path):
    """
    Download the file from the specified URL and save it in the specified path.
    """
    response = requests.get(url)

    if response.status_code == 200:
        output_path = os.path.join(save_path, filename)
        with open(output_path, 'wb') as f:
            f.write(response.content)
        file_size = os.path.getsize(output_path)
        print(f"File '{filename}' have been downloaded successfully! Size: {file_size/ (1024*1024):.2f} MB")
    else:
        print(f"There was an error loading the file '{filename}'. Status code: {response.status_code}.")


def get_result(args):
    params = {'hash': args.hash}
    save_path = args.output_path
    response = requests.get('https://mvsep.com/api/separation/get', params=params)
    data = json.loads(response.content.decode('utf-8'))

    if data['success']:
        try:
            files = data['data']['files']
        except:
            print("The separation is not ready yet")
            return None
        os.makedirs(save_path, exist_ok=True)
        print("Files to download: {}".format(len(files)))
        for file_info in files:
            url = file_info['url'].replace('\\/', '/')
            filename = file_info['download']
            download_file(url, filename, save_path)
    else:
        print("An error occurred while retrieving file data.")


def get_separation_types():
    api_url = 'https://mvsep.com/api/app/algorithms'
    response = requests.get(api_url)

    if response.status_code == 200:
        data = response.json()

        for algorithm in data:
            render_id = algorithm['render_id']
            name = algorithm['name']
            algorithm_group_id = algorithm['algorithm_group_id']

            algorithm_fields = algorithm['algorithm_fields']
            for field in algorithm_fields:
                field_name = field['name']
                field_text = field['text']
                field_options = field['options']

            algorithm_descriptions = algorithm['algorithm_descriptions']
            for description in algorithm_descriptions:
                short_desc = description['short_description']
                # long_desc = description['long_description']
                lang = description['lang']

            print(f"{render_id}: {name}, Group ID: {algorithm_group_id}")
            print(f"\tField Name: {field_name}, Field Text: {field_text}, Options: {field_options}")
            # print(f"\tShort Description: {short_desc}, Long Description: {long_desc}, Language: {lang}\n")
    else:
        print(f"Request failed with status code: {response.status_code}")


def parse_args(dict_args: Union[dict, None]) -> argparse.Namespace:
    """
    Parse command-line arguments for configuring the model, dataset, and training parameters.

    Args:
        dict_args: Dict of command-line arguments. If None, arguments will be parsed from sys.argv.

    Returns:
        Namespace object containing parsed arguments and their values.
    """
    parser = argparse.ArgumentParser(description="Console application for managing MVSEP separations.")
    subparsers = parser.add_subparsers(dest='command')

    get_types_parser = subparsers.add_parser('get_types', help="Get available separation types.")

    create_separation_parser = subparsers.add_parser('create_separation', help="Create a new separation.")
    create_separation_parser.add_argument('--input', type=str, help="Path to the file to be separated.")
    create_separation_parser.add_argument('--token', type=str, help="API token for authentication.")
    create_separation_parser.add_argument('--sep_type', type=str, help="Separation type.")
    create_separation_parser.add_argument('--add_opt1', type=str, default="", help="Additional option 1.")
    create_separation_parser.add_argument('--add_opt2', type=str, default="", help="Additional option 2.")

    get_result_parser = subparsers.add_parser('get_result', help="Get the result of a previously created separation.")
    get_result_parser.add_argument('--hash', type=str, help="Hash of the separation to retrieve.")
    get_result_parser.add_argument('--output_path', type=str, default="./", help="Path to store the result files.")

    if dict_args is not None:
        args = parser.parse_args([])
        args_dict = vars(args)
        args_dict.update(dict_args)
        args = argparse.Namespace(**args_dict)
    else:
        args = parser.parse_args()

    return args


def main():
    if len(sys.argv) > 1:
        args = parse_args(None)
        if args.command == 'create_separation':
            res = create_separation(args)
            if len(res) == 2:
                hash, return_code = res
                print('Hash: {} Return code: {}'.format(hash, return_code))
        if args.command == 'get_types':
            get_separation_types()
        if args.command == 'get_result':
            get_result(args)
    else:
        print("No arguments provided. Please provide command-line arguments.")


if __name__ == "__main__":
    main()
````

## File: python_example1/README.md
````markdown
### Simple example 1

[api_example.py](api_example.py) - this file allows to call 3 different methods:

1) Get list of all possible types of separation:
```bash
python3 api_example.py get_types
```

2) Create separation task with given parameters:
```bash
python3 api_example.py create_separation --input <path/to/file.mp3> --token <your_api_token> --sep_type <separation_type> --add_opt1 <add_opt1> --add_opt2 <add_opt2>
```
Note: `<your_api_token>` is available on MVSep site in your profile. You must have an account. 

For example if you have input.mp3 file located in folder with script you can use this command to separate with **Demucs4 HT (vocals, drums, bass, other)** model with model type: **"htdemucs (Good Quality, Fast)**":
```bash
python3 api_example.py create_separation --input input.mp3 --token DsemTWkdNyChZZWEjnHKVQAcjC543t --sep_type 20 --add_opt1 1 --add_opt2 0
```

This will put file in queue and print hash of file in terminal. After you can use this hash to download separated files.
Example of output: `Hash: 20250131145833-a0bb276157-mixture.wav Return code: 200`

3) Download result of separation
```bash
python3 api_example.py get_result --hash <hash from create_separation> --output_path <path where to store the files>
```
Note: `--output_path` is optional, if you don't set it files will be stored in current directory.

For example if you want to download files from previous step you can use this command:
```bash
python3 api_example.py get_result --hash 20250128141843-f0bb276157-mixture.wav
```

### Run without python on Windows

We create [exe version](api_example_win.exe) which can be run on Windows without python installed. To run just replace `python3 api_example.py` on `api_example_win.exe`. For example:

```bash
api_example_win.exe get_types
```
````

## File: python_example2/api_example2.py
````python
import os
import sys
import json
import requests
import argparse
import time
import glob
from typing import Union


def create_separation(file, args):
    files = {
        'audiofile': open(file, 'rb'),
        'api_token': (None, args.token),
        'sep_type': (None, args.sep_type),
        'add_opt1': (None, args.add_opt1),
        'add_opt2': (None, args.add_opt2),
        'output_format': (None, '1'),
        'is_demo': (None, '0'),
    }

    response = requests.post('https://mvsep.com/api/separation/create', files=files)
    string_response = response.content.decode('utf-8')
    parsed_json = json.loads(string_response)
    hash = parsed_json["data"]["hash"]

    return hash, response.status_code


def download_file(url, filename, save_path):
    """
    Download the file from the specified URL and save it in the specified path.
    """
    response = requests.get(url)

    if response.status_code == 200:
        output_path = os.path.join(save_path, filename)
        with open(output_path, 'wb') as f:
            f.write(response.content)
        file_size = os.path.getsize(output_path)
        print(f"File '{filename}' have been downloaded successfully! Size: {file_size/ (1024*1024):.2f} MB")
        return True
    else:
        print(f"There was an error loading the file '{filename}'. Status code: {response.status_code}.")
        return False


def get_result(hash, args):
    params = {'hash': hash}
    save_path = args.output_path
    response = requests.get('https://mvsep.com/api/separation/get', params=params)
    data = json.loads(response.content.decode('utf-8'))

    if data['success']:
        try:
            files = data['data']['files']
        except:
            # print("The separation is not ready yet")
            return None
        os.makedirs(save_path, exist_ok=True)
        print("\nFiles to download: {}".format(len(files)))
        for file_info in files:
            url = file_info['url'].replace('\\/', '/')
            filename = file_info['download']
            status = download_file(url, filename, save_path)
        if status:
            return True
        else:
            return False
    else:
        print("An error occurred while retrieving file data.")
        return False


def get_separation_types():
    api_url = 'https://mvsep.com/api/app/algorithms'
    response = requests.get(api_url)

    if response.status_code == 200:
        data = response.json()

        for algorithm in data:
            render_id = algorithm['render_id']
            name = algorithm['name']
            algorithm_group_id = algorithm['algorithm_group_id']

            algorithm_fields = algorithm['algorithm_fields']
            for field in algorithm_fields:
                field_name = field['name']
                field_text = field['text']
                field_options = field['options']

            algorithm_descriptions = algorithm['algorithm_descriptions']
            for description in algorithm_descriptions:
                short_desc = description['short_description']
                # long_desc = description['long_description']
                lang = description['lang']

            print(f"{render_id}: {name}, Group ID: {algorithm_group_id}")
            print(f"\tField Name: {field_name}, Field Text: {field_text}, Options: {field_options}")
            # print(f"\tShort Description: {short_desc}, Long Description: {long_desc}, Language: {lang}\n")
    else:
        print(f"Request failed with status code: {response.status_code}")


def parse_args(dict_args: Union[dict, None]) -> argparse.Namespace:
    """
    Parse command-line arguments for configuring the model, dataset, and training parameters.

    Args:
        dict_args: Dict of command-line arguments. If None, arguments will be parsed from sys.argv.

    Returns:
        Namespace object containing parsed arguments and their values.
    """
    parser = argparse.ArgumentParser(description="Console application for managing MVSEP separations.")
    subparsers = parser.add_subparsers(dest='command')

    get_types_parser = subparsers.add_parser('get_types', help="Get available separation types.")

    create_separation_parser = subparsers.add_parser('separate', help="Create a new separation.")
    create_separation_parser.add_argument('--input', type=str, help="Path to the folder where to search files to be separated.")
    create_separation_parser.add_argument('--output_path', type=str, default="./", help="Path to store the result files.")
    create_separation_parser.add_argument('--token', type=str, help="API token for authentication.")
    create_separation_parser.add_argument('--sep_type', type=str, help="Separation type.")
    create_separation_parser.add_argument('--add_opt1', type=str, default="", help="Additional option 1.")
    create_separation_parser.add_argument('--add_opt2', type=str, default="", help="Additional option 2.")

    if dict_args is not None:
        args = parser.parse_args([])
        args_dict = vars(args)
        args_dict.update(dict_args)
        args = argparse.Namespace(**args_dict)
    else:
        args = parser.parse_args()

    return args


def wait_to_response(hash, args):
    print("Wait while file will be processed on server", end='')
    counter = 0
    while counter < 360:
        response = get_result(hash, args)
        if response:
            break
        else:
            counter += 1
            print('...', end='')
            time.sleep(10)


def main():
    if len(sys.argv) > 1:
        args = parse_args(None)
        if args.command == 'separate':
            if not os.path.isdir(args.input):
                print('--input parameter must be a directory!')
                exit()
            files = []
            for extension in ['wav', 'flac', 'mp3']:
                files += glob.glob(os.path.join(args.input) + '/*.{}'.format(extension))
            print('Found files to process: {}'.format(len(files)))
            for file in files:
                print('Create separation task for file: {}'.format(file))
                res = create_separation(file, args)
                if len(res) == 2:
                    hash, return_code = res
                    print('Hash: {} Return code: {}'.format(hash, return_code))
                else:
                    print('Problem with separation', res)
                    continue
                wait_to_response(hash, args)

        if args.command == 'get_types':
            get_separation_types()
    else:
        print("No arguments provided. Please provide command-line arguments.")


if __name__ == "__main__":
    main()
````

## File: python_example2/README.md
````markdown
### Simple example 2

[api_example2.py](python_example2/api_example2.py) - this file allows to call 2 different methods:

1) Get list of all possible types of separation:
```bash
python3 api_example2.py get_types
```

2) Create separation task with given parameters:
```bash
python3 api_example2.py separate --input <path/to/folder/with/audio/files> --output_path <path where to store the files> --token <your_api_token> --sep_type <separation_type> --add_opt1 <add_opt1> --add_opt2 <add_opt2>
```
Note: `<your_api_token>` is available on MVSep site in your profile. You must have an account. 

For example if you have `input.mp3`, `input2.mp3` files located in folder `audio` in current directory you can use this command to separate with **MelBand Roformer (vocals, instrumental)** model with model type: **ver 2024.08 (SDR vocals: 11.17, SDR instrum: 17.48)**":
```bash
python3 api_example2.py separate --input "./audio/" --token DsemTWkdNyChZZWEjnHKVQAcjC543t --sep_type 48 --add_opt1 1
```
It will automatically put files in queue and download them when they are ready.

### Run without python on Windows

We create [exe version](python_example2/api_example2_win.exe) which can be run on Windows without python installed. To run just replace `python3 api_example2.py` on `api_example2_win.exe`. For example:

```bash
api_example2_win.exe get_types
```
````

## File: python_example3/mvsep_client.py
````python
import os
import time
import requests
from requests.exceptions import RequestException
from typing import Dict, List, Optional, Union
import json
import argparse


class MVSEPClient:
    def __init__(self, api_key: str, retries: int = 30, retry_interval: int = 20, debug: bool = True):
        self.api_key = api_key
        self.retries = retries
        self.retry_interval = retry_interval
        self.base_url = "https://mvsep.com/api"
        self.headers = {"User-Agent": "MVSEP Python Client/0.1"}
        self.debug = debug

    def _log_debug(self, message: str) -> None:
        """Helper method for debug logging"""
        if self.debug:
            print(f"[DEBUG] {message}")

    def _make_request(self, method: str, endpoint: str, 
                    params: Optional[Dict] = None, data: Optional[Dict] = None,
                    files: Optional[Dict] = None, stream: bool = False) -> requests.Response:
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        
        self._log_debug(f"Making {method} request to {url}")
        self._log_debug(f"Params: {params}")
        self._log_debug(f"Data: {data}")
        if files:
            self._log_debug(f"Files: {list(files.keys())} (content not logged)")
        
        for attempt in range(self.retries + 1):
            try:
                response = requests.request(
                    method, url,
                    params=params,
                    data=data,
                    files=files,
                    headers=self.headers,
                    stream=stream,
                    timeout=(600, 1200)
                )
                
                self._log_debug(f"Response status: {response.status_code}")
                self._log_debug(f"Response headers: {dict(response.headers)}")
                
                if response.status_code == 429:
                    retry_after = int(response.headers.get("Retry-After", self.retry_interval))
                    self._log_debug(f"Rate limited, retrying after {retry_after}s")
                    time.sleep(retry_after)
                    continue
                if response.status_code == 400:
                    #print(response)
                    time.sleep(self.retry_interval)
                    continue
                if 500 <= response.status_code < 600 and attempt < self.retries:
                    self._log_debug(f"Server error {response.status_code}, retrying...")
                    time.sleep(self.retry_interval)
                    continue

                response.raise_for_status()
                return response

            except requests.exceptions.HTTPError as e:
                self._log_debug(f"HTTP error: {str(e)}")
                if e.response.status_code // 100 == 4 and e.response.status_code != 429:
                    raise
                if attempt == self.retries:
                    raise
                time.sleep(self.retry_interval)
            except RequestException as e:
                self._log_debug(f"Request exception: {str(e)}")
                if attempt == self.retries:
                    raise Exception(f"Request failed after {self.retries} retries: {str(e)}")
                time.sleep(self.retry_interval)
        raise Exception("Unexpected error in request handling")

    # Core Separation Functions (updated with debug logs)
    def create_separation(self, file_path: Optional[str] = None, url: Optional[str] = None,
                        sep_type: int = 11, add_opt1: Optional[Union[str, int]] = None,
                        add_opt2: Optional[Union[str, int]] = None, add_opt3: Optional[Union[str, int]] = None,
                        output_format: int = 0, is_demo: bool = False,
                        remote_type: Optional[str] = None) -> Dict:
        self._log_debug(f"Creating separation with params: sep_type={sep_type}, output_format={output_format}")
        
        data = {
            "api_token": self.api_key,
            "sep_type": str(sep_type),
            "output_format": str(output_format),
            "is_demo": "1" if is_demo else "0"
        }
        files = {}
        
        if file_path and url:
            raise ValueError("Cannot specify both file_path and url")
        if file_path:
            self._log_debug(f"Uploading local file: {file_path}")
            files["audiofile"] = open(file_path, "rb")
        elif url:
            self._log_debug(f"Processing remote URL: {url}")
            data["url"] = url
            if remote_type:
                data["remote_type"] = remote_type
        else:
            raise ValueError("Either file_path or url must be provided")
        
        for opt, val in [("add_opt1", add_opt1), ("add_opt2", add_opt2), ("add_opt3", add_opt3)]:
            if val is not None:
                data[opt] = str(val)
        
        response = self._make_request("POST", "separation/create", data=data, files=files)
        json_response = response.json()
        self._log_debug(f"Create separation response: {json_response}")
        return json_response

    def get_separation_status(self, task_hash: str, mirror: int = 0) -> Dict:
        self._log_debug(f"Getting status for hash: {task_hash}, mirror={mirror}")
        params = {"hash": task_hash, "mirror": str(mirror)}
        if mirror == 1:
            params["api_token"] = self.api_key
        response = self._make_request("GET", "separation/get", params=params)
        json_response = response.json()
        self._log_debug(f"Status response: {json_response}")
        return json_response

    def download_track(self, url: str, output_path: str) -> None:
        """Download a track directly using the full URL from the API response"""
        self._log_debug(f"Downloading track directly from {url}")
        
        # Bypass the base URL since we have full download URLs
        response = requests.get(url, stream=True, headers=self.headers)
        response.raise_for_status()
        
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
        self._log_debug(f"Finished downloading to {output_path}")


    # Updated process_directory with debug logs
    def process_directory(self, input_dir: str, output_dir: str, **kwargs) -> None:
        self._log_debug(f"Processing directory: {input_dir} -> {output_dir}")
        supported_ext = [".mp3", ".wav", ".flac"]
        os.makedirs(output_dir, exist_ok=True)
        filtered_files = os.listdir(input_dir)

        for filename in filtered_files:
            if os.path.splitext(filename)[1].lower() not in supported_ext:
                self._log_debug(f"Skipping unsupported file: {filename}")
                continue
            
            file_path = os.path.join(input_dir, filename)
            self._log_debug(f"Processing {filename}")
            
            try:
                create_resp = self.create_separation(file_path=file_path, **kwargs)
                if not create_resp.get("success"):
                    self._log_debug(f"Creation failed response: {create_resp}")
                    continue
                
                task_hash = create_resp["data"]["hash"]
                self._log_debug(f"Created separation task: {task_hash}")
                
                while True:
                    status_resp = self.get_separation_status(task_hash)
                    self._log_debug(f"Status poll response: {status_resp}")
                    
                    status = status_resp.get("status")
                    if status == "done":
                        self._log_debug("Processing completed successfully")
                        break
                    if status in ["failed", "error"]:
                        self._log_debug("Processing failed")
                        break
                    if status in ["waiting", "processing", "distributing", "merging"]:
                        self._log_debug(f"Current status: {status}, waiting {self.retry_interval}s")
                        time.sleep(self.retry_interval)
                    else:
                        self._log_debug(f"Unknown status: {status}")
                        break
                
                if status != "done":
                    continue
                
                # FIXED: Use 'download' key instead of 'name'
                for file_info in status_resp["data"]["files"]:
                    output_filename = file_info.get("download", f"unknown_{time.time()}.mp3")
                    output_path = os.path.join(output_dir, output_filename)
                    self._log_debug(f"Downloading {output_filename}")
                    # FIXED: Use 'url' key instead of 'link'
                    self.download_track(file_info["url"], output_path)
            
            except Exception as e:
                self._log_debug(f"Exception during processing: {str(e)}")
                print(f"Error processing {filename}: {str(e)}")

    # Updated get_algorithms with debug logs
    def get_algorithms(self) -> Dict:
        self._log_debug("Fetching algorithm list")
        response = self._make_request("GET", "app/algorithms")
        sorted_algos = sorted(response.json(), key=lambda algo: algo['render_id'])
        algo_dict = {}

        for algo in sorted_algos:
            s1 = f"\nID:{algo['render_id']} - {algo['name']}"
            algo_dict[algo['render_id']] = s1 + '\n'
            # print(s1)
            for field in algo['algorithm_fields']:
                s1 = f"\t{field['name']}"
                algo_dict[algo['render_id']] += s1 + '\n'
                # print(s1)
                options = json.loads(field['options'])
                for key, value in sorted(options.items()):
                    s1 = f"\t\t{key}: {value}"
                    algo_dict[algo['render_id']] += s1 + '\n'
                    # print(s1)
        return algo_dict

    # Premium Management
    def enable_premium(self) -> Dict:
        data = {"api_token": self.api_key}
        response = self._make_request("POST", "app/enable_premium", data=data)
        return response.json()

    def disable_premium(self) -> Dict:
        data = {"api_token": self.api_key}
        response = self._make_request("POST", "app/disable_premium", data=data)
        return response.json()

    # Quality Checker
    def create_quality_entry(self, zip_path: str, algo_name: str, main_text: str,
                            dataset_type: int = 0, ensemble: int = 0, password: str = "") -> Dict:
        data = {
            "api_token": self.api_key,
            "algo_name": algo_name,
            "main_text": main_text,
            "dataset_type": str(dataset_type),
            "ensemble": str(ensemble),
            "password": password
        }
        files = {"zipfile": open(zip_path, "rb")}
        response = self._make_request("POST", "quality_checker/add", data=data, files=files)
        return response.json()

    # Additional API Endpoints
    def get_queue_info(self) -> Dict:
        response = self._make_request("GET", "app/queue")
        return response.json()

    def get_news(self, lang: str = "en", start: int = 0, limit: int = 10) -> Dict:
        params = {"lang": lang, "start": start, "limit": limit}
        response = self._make_request("GET", "app/news", params=params)
        return response.json()

    def get_separation_history(self, start: int = 0, limit: int = 10) -> Dict:
        params = {"api_token": self.api_key, "start": start, "limit": limit}
        response = self._make_request("GET", "app/separation_history", params=params)
        return response.json()

    # File Name Preferences
    def enable_long_filenames(self) -> Dict:
        data = {"api_token": self.api_key}
        response = self._make_request("POST", "app/enable_long_filenames", data=data)
        return response.json()

    def disable_long_filenames(self) -> Dict:
        data = {"api_token": self.api_key}
        response = self._make_request("POST", "app/disable_long_filenames", data=data)
        return response.json()


def parse_args(dict_args: Union[dict, None]) -> argparse.Namespace:
    """
    Parse command-line arguments for configuring the model, dataset, and training parameters.

    Args:
        dict_args: Dict of command-line arguments. If None, arguments will be parsed from sys.argv.

    Returns:
        Namespace object containing parsed arguments and their values.
    """
    parser = argparse.ArgumentParser(description="Console application for managing MVSEP separations.")
    subparsers = parser.add_subparsers(dest='command')

    get_types_parser = subparsers.add_parser('get_types', help="Get available separation types.")
    get_types_parser.add_argument('--token', type=str, help="API token for authentication.")

    create_separation_parser = subparsers.add_parser('separate', help="Create a new separation.")
    create_separation_parser.add_argument('--input', type=str, help="Path to the folder where to search files to be separated.")
    create_separation_parser.add_argument('--output_folder', type=str, default="./", help="Path to store the result files.")
    create_separation_parser.add_argument('--token', type=str, help="API token for authentication.")
    create_separation_parser.add_argument('--output_format', type=int, default=1, help="Output format: MP3=0, WAV=1, FLAC=2")
    create_separation_parser.add_argument('--sep_type', type=int, default=20, help="Separation type.")
    create_separation_parser.add_argument('--add_opt1', type=str, default="", help="Additional option 1.")
    create_separation_parser.add_argument('--add_opt2', type=str, default="", help="Additional option 2.")
    create_separation_parser.add_argument('--add_opt3', type=str, default="", help="Additional option 3.")

    args = parser.parse_args()
    return args


if __name__ == "__main__":
    args = parse_args(None)

    # Example Usage
    API_KEY = args.token
    client = MVSEPClient(api_key=API_KEY, debug=True)  # USE DEBUG, ELSE NOTHING WILL BE PRINTED ON TERMINAL, normal prints are not done yet

    if args.command == 'separate':
        algos = client.get_algorithms()
        print('Separate with algorithm: {}'.format(args.sep_type))
        print(algos[args.sep_type])

        # Process directory example / need to check if retries are working correctly !!!
        client.process_directory(
            input_dir = args.input,
            output_dir = args.output_folder,
            output_format = args.output_format,  # MP3=0, WAV=1, FLAC=2
            sep_type = args.sep_type, # use client.get_algorithms() or check documentation details https://mvsep.com/en/full_api for now
            add_opt1 = args.add_opt1, # use client.get_algorithms() or check documentation details https://mvsep.com/en/full_api for now
            add_opt2 = args.add_opt2, # use client.get_algorithms() or check documentation details https://mvsep.com/en/full_api for now
            add_opt3 = args.add_opt3, # use client.get_algorithms() or check documentation details https://mvsep.com/en/full_api for now
        )
    else:
        # Get algos formated list : DONE !
        algos = client.get_algorithms()
        for algo in algos:
            print(algos[algo])
````

## File: python_example3/README.md
````markdown
### Example 3

[mvsep_client.py](python_example3/mvsep_client.py) - this file allows to call 2 different methods:

1) Get list of all possible types of separation:
```bash
python3 mvsep_client.py get_types --token <your_api_token>
```

2) Create separation task with given parameters:
```bash
python3 mvsep_client.py separate --input <path/to/folder/with/audio/files> --output_folder <path where to store the files> --output_format <MP3=0, WAV=1, FLAC=2> --token <your_api_token> --sep_type <separation_type> --add_opt1 <add_opt1> --add_opt2 <add_opt2> --add_opt3 <add_opt3>
```
Note: `<your_api_token>` is available on MVSep site in your profile. You must have an account. 

For example if you have `input.mp3`, `input2.mp3` files located in folder `audio` in current directory you can use this command to separate with **MelBand Roformer (vocals, instrumental)** model with model type: **ver 2024.08 (SDR vocals: 11.17, SDR instrum: 17.48)**":
```bash
python3 mvsep_client.py separate --input "./audio/" --token DsemTWkdNyChZZWEjnHKVQAcjC543t --sep_type 48 --add_opt1 1
```
It will automatically put files in queue and download them when they are ready.

### Run without python on Windows

We create [exe version](python_example3/mvsep_client_win.exe) which can be run on Windows without python installed. To run just replace `python3 mvsep_client.py` on `mvsep_client_win.exe`. For example:

```bash
mvsep_client_win.exe get_types
```
````

## File: python_example4_gui/mvsep_client_gui.py
````python
import time, os, json

from PyQt6.QtWidgets import (
    QApplication, QWidget, QPushButton, QVBoxLayout, QLabel, QDialog,
    QComboBox, QLineEdit, QFileDialog, QSpinBox, QMessageBox, QScrollArea
)
import sys
import requests
import json
from PyQt6.QtCore import QMimeData, Qt, QThread, pyqtSignal, pyqtSlot
from PyQt6.QtGui import QDrag

# File directory
BASE_DIR = os.path.abspath(os.path.dirname(__file__))

# Universal style for buttons and input fields (increased sizes)
button_style = "font-size: 18px; padding: 20px; min-width: 300px; font-family: 'Poppins', sans-serif;"
# Create Separation style
cs_button_style = "font-size: 18px; padding: 20px; min-width: 300px; font-family: 'Poppins', sans-serif; background-color: #0176b3; border-radius: 0.3rem;"
input_style = "font-size: 18px; padding: 15px; min-width: 300px; font-family: 'Poppins', sans-serif;"  # Style for text fields and other elements
# Setting the text style
label_style = "font-size: 16px; font-family: 'Poppins', sans-serif;"
combo_style = " font-size: 16px; font-family: 'Poppins'; padding: 20px; "

# Style for dialog backgrounds
dialog_background = """
    background: linear-gradient(to bottom, blue, white);
    border: none;
    margin: 0;
    padding: 0;
"""

stylesheet = """
QWidget {
    # background: qlineargradient(x1: 0, y1: 0, x2: 1, y2: 1, 
                                stop: 0 #0176B3, stop: 0.5 #1E9BDC, stop: 1 #FFFFFF);
}
"""

path_hash_dict = {}
separation_n = 0


def get_separation_types():
    # Request URL
    api_url = 'https://mvsep.com/api/app/algorithms'

    # Making a GET request
    response = requests.get(api_url)

    # Checking the response status code
    if response.status_code == 200:
        # Parsing the response into JSON
        data = response.json()
        result = {}  # Creating a new dictionary to save data by render_id
        algorithm_fields_result = {}

        # Data structure check (for debugging)
        if isinstance(data, list):  # Checking that data is a list
            for algorithm in data:
                if isinstance(algorithm, dict):  # Checking that each element is a dictionary
                    render_id = algorithm.get('render_id', 'N/A')
                    name = algorithm.get('name', 'N/A')
                    algorithm_group_id = algorithm.get('algorithm_group_id', 'N/A')
                    # print(f"{render_id}: {name}, Group ID: {algorithm_group_id}")

                    # Additional fields
                    algorithm_fields = algorithm.get('algorithm_fields', [])
                    for field in algorithm_fields:
                        if isinstance(field, dict):
                            field_name = field.get('name', 'N/A')
                            field_text = field.get('text', 'N/A')
                            field_options = field.get('options', 'N/A')
                            # Printing additional fields (can be removed if not needed)
                            # print(f"\tField Name: {field_name}, Field Text: {field_text}, Options: {field_options}")

                    # Algorithm descriptions
                    algorithm_descriptions = algorithm.get('algorithm_descriptions', [])
                    for description in algorithm_descriptions:
                        if isinstance(description, dict):
                            short_desc = description.get('short_description', 'N/A')
                            lang = description.get('lang', 'N/A')
                            # Printing algorithm description (can be removed if not needed)
                            # print(f"\tShort Description: {short_desc}, Language: {lang}")

                    # Saving data to result by render_id
                    result[render_id] = name
                    # Printing data for example
                    # print(f"{render_id}: {name}, Group ID: {algorithm_group_id}")

                    algorithm_fields_result[render_id] = algorithm_fields

        else:
            print(f"Unexpected top-level data format: {data}")

        # Returning the result (can be used for further processing)
        # print(result)
        return result, algorithm_fields_result
    else:
        print(f"Request failed with status code: {response.status_code}")


def download_file(url, filename, save_path):
    """
    Download the file from the specified URL and save it in the specified path.
    """
    print("start download")
    response = requests.get(url)
    print("end download")

    if response.status_code == 200:
        # Ensure the directory exists
        if not os.path.exists(save_path):
            os.makedirs(save_path)

        file_path = os.path.join(save_path, filename)

        # Save the content of the response to the file
        with open(file_path, 'wb') as f:
            f.write(response.content)
        return f"File '{filename}' was downloaded successfully!"
    else:
        print(f"There was an error downloading the file '{filename}'. Status code: {response.status_code}.")


def get_result(hash, save_path):
    success, data = check_result(hash)
    if success:
        try:
            files = data['data']['files']
        except KeyError:
            print("The separation is not ready yet.")
            return ""
        text = ""
        for file_info in files:
            url = file_info['url'].replace('\\/', '/')  # Correct slashes
            filename = file_info['download']  # File name for saving
            text += f'{download_file(url, filename, save_path)}\n'
        return text
    else:
        print("An error occurred while retrieving file data.")


def check_result(hash):
    params = {'hash': hash}
    response = requests.get('https://mvsep.com/api/separation/get', params=params)
    data = json.loads(response.content.decode('utf-8'))

    return data['success'], data


def create_separation(path_to_file, api_token, sep_type, add_opt1, add_opt2, add_opt3):
    files = {
        'audiofile': open(path_to_file, 'rb'),
        'api_token': (None, api_token),
        'sep_type': (None, sep_type),
        'add_opt1': (None, add_opt1),
        'add_opt2': (None, add_opt2),
        'add_opt3': (None, add_opt3),
        'output_format': (None, '1'),
        'is_demo': (None, '0'),
    }
    print("files")
    print(files)

    response = requests.post('https://mvsep.com/api/separation/create', files=files)
    if response.status_code == 200:
        response_content = response.content

        # Converting byte array to string
        string_response = response_content.decode('utf-8')

        # Parsing string into JSON
        parsed_json = json.loads(string_response)

        # Outputting the result
        hash = parsed_json["data"]["hash"]

        return hash, response.status_code
    else:
        return response.content, response.status_code


class SepThread(QThread):
    stop_separation_signal = pyqtSignal(str)

    def __init__(self, parent=None):
        super(SepThread, self).__init__(parent)
        self.hash = ""

    def run(self):
        global separation_n, path_hash_dict
        i = 0
        while i < 180:
            # Getting the result
            output_dir = path_hash_dict[self.hash]
            result_text = get_result(self.hash, output_dir)
            print(f"i={i}; {self.hash}")
            print(path_hash_dict)
            if result_text != "":
                # Displaying the text result in the dialog
                separation_n -= 1
                print("good separation break")
                print(result_text)
                self.stop_separation_signal.emit(result_text)
                break
            else:
                i += 1
                time.sleep(1)
            print()

        if i == 179:
            # Displaying a negative result in the dialog
            separation_n -= 1
            self.stop_separation_signal.emit("No result per 3 min.")


class DragButton(QPushButton):
    dragged = pyqtSignal()

    def dragEnterEvent(self, e):
        print("dragEnterEvent")
        e.accept()

    def dropEvent(self, event):
        self.selected_file = ""
        if event.mimeData().hasUrls():
            for url in event.mimeData().urls():
                file_path = url.toLocalFile()
                self.selected_file = file_path
            event.accept()
            self.dragged.emit()
        else:
            event.ignore()

    def mouseMoveEvent(self, e):
        if e.buttons() == Qt.MouseButton.LeftButton:
            drag = QDrag(self)
            mime = QMimeData()
            drag.setMimeData(mime)
            drag.exec(Qt.DropAction.MoveAction)


class MainWindow(QWidget):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("MVSep Separator GUI")
        self.setGeometry(50, 50, 400, 400)
        self.setFixedSize(400, 800)
        layout = QVBoxLayout()

        self.token_filename = os.path.join(BASE_DIR, "api_token.txt")
        self.selected_file = None
        self.output_dir = BASE_DIR + '/'
        self.algorithm_fields = {}

        self.alg_opt1 = {}
        self.alg_opt2 = {}
        self.alg_opt3 = {}

        self.selected_opt1 = 0
        self.selected_opt2 = 0
        self.selected_opt3 = 0

        # Separation type selection field
        self.type_label = QLabel("Separation Type")
        self.type_label.setStyleSheet(label_style)

        self.data, self.algorithm_fields = get_separation_types()

        # Sorting the dictionary by key
        sorted_data = {k: v for k, v in sorted(self.data.items())}

        # Initializing QComboBox
        self.type_combo = QComboBox(self)
        value = sorted_data.values()
        # Adding items to the combobox
        self.type_combo.addItems(value)

        # Setting up the selection handler
        self.type_combo.currentIndexChanged.connect(self.on_selection_change)

        self.type_combo.setStyleSheet(combo_style)
        layout.addWidget(self.type_label)
        layout.addWidget(self.type_combo)

        # API Token field
        self.api_label = QLabel("API Token")
        self.api_label.setStyleSheet(label_style)
        self.api_input = QLineEdit()
        self.api_input.setStyleSheet(input_style)
        # Looking for the token file
        if os.path.isfile(self.token_filename):
            with open(self.token_filename, "r") as f:
                api_token = f.read().strip()
                if len(api_token) == 30:
                    self.api_input.setText(api_token)

        layout.addWidget(self.api_label)
        layout.addWidget(self.api_input)

        # API Token link
        self.api_link_label = QLabel("<a href='https://mvsep.com/ru/full_api'>Get Token</a>")
        self.api_link_label.setStyleSheet(label_style)
        self.api_link_label.setOpenExternalLinks(True)
        layout.addWidget(self.api_link_label)

        # Adding additional options 1, 2, 3
        self.option1_label = QLabel("Additional Option 1")
        self.option1_label.setStyleSheet(label_style)

        # Initializing QComboBox
        self.option1_combo = QComboBox(self)
        self.option1_combo.setStyleSheet(combo_style)

        # Setting up the selection handler
        self.option1_combo.currentIndexChanged.connect(self.on_change_option1)
        layout.addWidget(self.option1_label)
        layout.addWidget(self.option1_combo)

        # Adding additional options 1, 2, 3
        self.option2_label = QLabel("Additional Option 2")
        self.option2_label.setStyleSheet(label_style)

        # Initializing QComboBox
        self.option2_combo = QComboBox(self)
        self.option2_combo.setStyleSheet(combo_style)

        # Setting up the selection handler
        self.option2_combo.currentIndexChanged.connect(self.on_change_option2)
        layout.addWidget(self.option2_label)
        layout.addWidget(self.option2_combo)

        # Adding additional options 1, 2, 3
        self.option3_label = QLabel("Additional Option 3")
        self.option3_label.setStyleSheet(label_style)

        # Initializing QComboBox
        self.option3_combo = QComboBox(self)
        self.option3_combo.setStyleSheet(combo_style)

        # Setting up the selection handler
        self.option3_combo.currentIndexChanged.connect(self.on_change_option3)
        layout.addWidget(self.option3_label)
        layout.addWidget(self.option3_combo)

        # Selected audio file
        self.filename_label = QLabel("Audio selected:")
        self.filename_label.setStyleSheet(label_style)
        self.filename_label.setOpenExternalLinks(True)
        layout.addWidget(self.filename_label)

        # File selection button
        self.file_button = DragButton("Select File")
        self.file_button.setAcceptDrops(True)
        self.file_button.setStyleSheet(button_style)
        self.file_button.clicked.connect(self.select_file)
        self.file_button.dragged.connect(self.select_drag_file)

        layout.addWidget(self.file_button)

        # Selected output directory
        self.output_dir_label = QLabel(f"Output Dir: {self.output_dir}")
        self.output_dir_label.setStyleSheet(label_style)
        layout.addWidget(self.output_dir_label)
        # Button for selecting the output directory
        self.output_dir_button = QPushButton("Select Output Dir")
        self.output_dir_button.setStyleSheet(button_style)
        self.output_dir_button.clicked.connect(self.select_output_dir)
        layout.addWidget(self.output_dir_button)

        # Button to create separation
        self.create_button = QPushButton("Create Separation")
        self.create_button.setStyleSheet(cs_button_style)
        self.create_button.clicked.connect(self.process_separation)
        layout.addWidget(self.create_button)

        self.setLayout(layout)

    def select_file(self):
        # Opening a dialog to select a file
        file_path, _ = QFileDialog.getOpenFileName(self, "Select File", "", "Audio Files (*.mp3 *.wav)")
        if file_path:
            self.selected_file = file_path
            print(f"File selected: {self.selected_file}")
            self.filename_label.setText(f"Audio selected: {os.path.basename(self.selected_file)}")

    def select_drag_file(self):
        self.selected_file = self.file_button.selected_file
        print(f"File selected: {self.selected_file}")
        self.filename_label.setText(f"Audio selected: {os.path.basename(self.selected_file)}")

    def on_selection_change(self, index):
        # Getting the selected text
        selected_item = self.type_combo.currentText()

        # Finding the corresponding key for the selected value
        for key, value in self.data.items():
            if value == selected_item:
                self.selected_key = key
                print(f"Selected key: {self.selected_key} - {selected_item}")

                selected_algorithm = self.algorithm_fields[key]
                print("Options Len:")
                print(len(selected_algorithm))
                print("Options:")
                print(selected_algorithm)

                # Clearing all ComboBoxes
                self.option1_combo.clear()
                self.option2_combo.clear()
                self.option3_combo.clear()
                self.option1_label.setText("Additional Option 1")
                self.option2_label.setText("Additional Option 2")
                self.option3_label.setText("Additional Option 3")

                if len(self.algorithm_fields[key]) > 0:
                    self.option1_label.setText(f"Additional Option 1: {selected_algorithm[0]['text']}")
                    self.alg_opt1 = json.loads(selected_algorithm[0]['options'])
                    # Sorting the dictionary by key
                    sorted_data = {k: v for k, v in sorted(self.alg_opt1.items())}
                    value = sorted_data.values()
                    # Adding items to the combobox
                    self.option1_combo.addItems(value)

                if len(self.algorithm_fields[key]) > 1:
                    self.option2_label.setText(f"Additional Option 2: {selected_algorithm[1]['text']}")
                    self.alg_opt2 = json.loads(selected_algorithm[1]['options'])
                    # Sorting the dictionary by key
                    sorted_data = {k: v for k, v in sorted(self.alg_opt2.items())}
                    value = sorted_data.values()
                    # Adding items to the combobox
                    self.option2_combo.addItems(value)

                if len(self.algorithm_fields[key]) > 2:
                    self.option3_label.setText(f"Additional Option 3: {selected_algorithm[2]['text']}")
                    self.alg_opt3 = json.loads(selected_algorithm[2]['options'])
                    # Sorting the dictionary by key
                    sorted_data = {k: v for k, v in sorted(self.alg_opt3.items())}
                    value = sorted_data.values()
                    # Adding items to the combobox
                    self.option3_combo.addItems(value)
                break

    def on_change_option1(self, index):
        # Getting the selected text
        selected_item = self.option1_combo.currentText()
        # Finding the corresponding key for the selected value
        for key, value in self.alg_opt1.items():
            if value == selected_item:
                self.selected_opt1 = key
                break

    def on_change_option2(self, index):
        # Getting the selected text
        selected_item = self.option2_combo.currentText()
        # Finding the corresponding key for the selected value
        for key, value in self.alg_opt2.items():
            if value == selected_item:
                self.selected_opt2 = key
                break

    def on_change_option3(self, index):
        # Getting the selected text
        selected_item = self.option3_combo.currentText()
        # Finding the corresponding key for the selected value
        for key, value in self.alg_opt3.items():
            if value == selected_item:
                self.selected_opt3 = key
                break

    def select_output_dir(self):
        # Opening a dialog to select a directory
        self.output_dir = QFileDialog.getExistingDirectory(self, "Select Folder to Save")
        self.output_dir_label.setText(f"Output Dir: {self.output_dir}")

    def process_separation(self):
        global path_hash_dict, start_result, separation_n
        for key, value in self.data.items():
            if value == self.type_combo.currentText():
                self.selected_key = key
                break
        separation_type = self.selected_key
        api_token = self.api_input.text()
        option1 = self.selected_opt1
        option2 = self.selected_opt2
        option3 = self.selected_opt3
        path = self.selected_file

        # Clearing field styles before validation
        self.clear_styles()
        # Validation
        if not path:  # If no file is selected
            self.file_button.setStyleSheet(
                "background-color: red; font-size: 18px; padding: 20px; min-width: 300px;")  # Highlighting the button in red
        if not api_token:  # If API token is empty
            self.api_input.setStyleSheet("border: 2px solid red; font-size: 18px; padding: 15px; min-width: 300px;")
        else:
            # Save to file
            with open(self.token_filename, "w") as f:
                f.write(api_token)

        if not separation_type:  # If separation type is not selected
            self.type_combo.setStyleSheet(f"border: 2px solid red; {combo_style}")

        # Check: if there are errors, do not continue the process
        if (path == None) or not api_token or not separation_type:
            os.system('cls')
            print("Error separation:")
            print(f"path: {path}")
            print(f"api_token: {api_token}")
            print(f"separation_type: {separation_type}")
            return

        # Trying to start separation (e.g., generate a hash or error)
        result = self.start_separation(separation_type, api_token, option1, option2, option3, path)
        if 'hash' in result:
            # Connecting the separation progress check thread
            path_hash_dict[result["hash"]] = self.output_dir
            start_result = result
            separation_n += 1
            self.create_button.setText(f"Create Separation: [{separation_n} in progress]")
            self.st = SepThread(self)
            self.st.stop_separation_signal.connect(self.stop_separation)
            self.st.hash = result["hash"]
            self.st.start()
            QMessageBox.information(self, "Result", f"Thread #{separation_n}\nin progress")

    def stop_separation(self, result_text):
        global separation_n
        # Completion of separation
        QMessageBox.information(self, "Result", result_text)
        self.create_button.setText(f"Create Separation: [{separation_n}]")

    def clear_styles(self):
        # Resetting styles
        self.file_button.setStyleSheet(button_style)
        self.api_input.setStyleSheet(input_style)
        self.type_combo.setStyleSheet(combo_style)

    def start_separation(self, separation_type, api_token, option1, option2, option3, path):
        hash, status_code = create_separation(path, api_token, separation_type, option1, option2, option3)
        if status_code == 200:
            return {"success": True, "hash": hash}  # Success with hash
        else:
            return {"success": False, "error": hash}

    def show_separation_types(self):
        # Creating a form to display separation types
        separation_dialog = QDialog(self)
        separation_dialog.setWindowTitle("Separation Types")

        # Getting and sorting data
        self.data = get_separation_types()
        sorted_data = {k: v for k, v in sorted(self.data.items())}

        # Creating QScrollArea for scrolling
        scroll_area = QScrollArea(separation_dialog)
        scroll_area.setWidgetResizable(True)

        # Creating a container for QLabel to use it in ScrollArea
        label_widget = QWidget()
        label_layout = QVBoxLayout(label_widget)

        # Forming data rows and adding them to the layout as QLabel
        for key, value in sorted_data.items():
            label = QLabel(f"{key}: {value}", label_widget)
            label.setStyleSheet(label_style)  # Applying the text style
            label_layout.addWidget(label)

        # Setting the QLabel container in ScrollArea
        scroll_area.setWidget(label_widget)

        # Creating a button to close the form
        close_button = QPushButton("Close", separation_dialog)
        close_button.setStyleSheet(button_style)  # Applying the button style
        close_button.clicked.connect(separation_dialog.accept)

        # Creating the main layout and adding ScrollArea and a button to it
        layout = QVBoxLayout(separation_dialog)
        layout.addWidget(scroll_area)
        layout.addWidget(close_button)

        # Setting the layout in the dialog window
        separation_dialog.setLayout(layout)

        # Displaying the dialog window
        separation_dialog.exec()

    def show_get_result(self):
        dialog = GetResultDialog(self)
        dialog.exec()


class GetResultDialog(QDialog):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Get Separation Result")
        self.setGeometry(150, 150, 400, 200)

        layout = QVBoxLayout()

        # Label and field for hash input
        self.hash_label = QLabel("Enter Hash")
        self.hash_input = QLineEdit()
        self.hash_input.setPlaceholderText("Enter the hash to check")
        self.hash_input.setStyleSheet(input_style)
        layout.addWidget(self.hash_label)
        layout.addWidget(self.hash_input)

        # Check button
        self.check_button = QPushButton("Check")
        self.check_button.setStyleSheet(button_style)
        self.check_button.clicked.connect(self.check_hash)
        layout.addWidget(self.check_button)

        self.setLayout(layout)

    def check_hash(self):
        # Getting the entered hash
        hash_value = self.hash_input.text().strip()

        if not hash_value:
            QMessageBox.warning(self, "Input Error", "Please enter a valid hash.")
            return

        # Checking the hash status
        result = self.check_status(hash_value)

        # If the status is successful, open a dialog to select a folder
        if result["success"]:
            folder_path = QFileDialog.getExistingDirectory(self, "Select Folder to Save")
            if folder_path:
                # Getting the result
                result_text = get_result(hash_value, folder_path)
                if result_text != "":
                    # Displaying the text result in the dialog
                    self.show_result(result_text)
        else:
            # If an error occurred, show a message
            QMessageBox.warning(self, "Error", "An error occurred while retrieving file data.")

    def check_status(self, hash_value):
        success, data = check_result(hash_value)
        return {"success": success}  # Successful result

    def show_result(self, result_text):
        # Showing the result in a new window with text
        QMessageBox.information(self, "Result", result_text)


class ResultDialog(QDialog):
    def __init__(self, parent, result):
        super().__init__(parent)
        self.setWindowTitle("Separation Result")
        self.setGeometry(150, 150, 400, 200)
        layout = QVBoxLayout()

        if result["success"]:
            # If successful result, show the hash
            self.result_label = QLabel(f"Separation Successful!\nHash: {result['hash']}")
            self.result_label.setStyleSheet(label_style)
            self.result_input = QLineEdit(result['hash'])
            self.result_input.setStyleSheet(input_style)
            self.result_input.setReadOnly(True)  # Making the field read-only
            layout.addWidget(self.result_label)
            layout.addWidget(self.result_input)
        else:
            # If error, show an error message
            self.result_label = QLabel(f"Error: {result['error']}")
            layout.addWidget(self.result_label)

        self.setLayout(layout)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    main_window = MainWindow()
    main_window.show()
    sys.exit(app.exec())
````

## File: python_example4_gui/README.md
````markdown
### Example 4

Simple GUI for creating separation using MVSep API. You can run it with 2 methods:
1) `python3 mvsep_client_gui.py`
2) `mvsep_client_gui_win.exe` - binary file for Windows 10/11 you can run directly without python installed.

You can modify this client for your needs easily.

#### Interface

![Interface for MVSep GUI](images/GUI-Interface.png)
````

## File: python_example5_gui/mvsep_client_gui.py
````python
import time, os, json
import sqlite3, requests
from datetime import datetime

from PyQt6.QtWidgets import (
    QApplication, QWidget, QPushButton, QAbstractItemView, QGridLayout, QLabel, QDialog,
    QComboBox, QLineEdit, QFileDialog, QTableWidget, QMessageBox, QScrollArea, QTableWidgetItem, QTextEdit
)
import sys
from PyQt6.QtCore import QMimeData, Qt, QThread, pyqtSignal, pyqtSlot
from PyQt6.QtGui import QDrag
from PyQt6.QtGui import QIcon

# File directory
if getattr(sys, 'frozen', False):
    BASE_DIR = os.path.dirname(sys.executable)
else:
    BASE_DIR = os.path.abspath(os.getcwd())
connection = sqlite3.connect(os.path.join(BASE_DIR, 'jobs.db'), check_same_thread=False)

# Universal style for buttons and input fields (increased sizes)
button_style = "font-size: 18px; padding: 20px; min-width: 300px; font-family: 'Poppins', sans-serif;"
# Create Separation button style
cs_button_style = "font-size: 18px; padding: 20px; min-width: 300px; font-family: 'Poppins', sans-serif; background-color: #0176b3; border-radius: 0.3rem;"
input_style = "font-size: 18px; padding: 15px; min-width: 300px; font-family: 'Poppins', sans-serif;"  # Style for text fields and other elements
# Text style
label_style = "font-size: 16px; font-family: 'Poppins', sans-serif;"
small_label_style = "font-size: 12px; font-family: 'Poppins', sans-serif;"
combo_style = " font-size: 16px; font-family: 'Poppins'; padding: 20px; "

# Dialog background style
dialog_background = """
    background: linear-gradient(to bottom, blue, white);
    border: none;
    margin: 0;
    padding: 0;
"""

stylesheet = """
QWidget {
    # background: qlineargradient(x1: 0, y1: 0, x2: 1, y2: 1,
                                stop: 0 #0176B3, stop: 0.5 #1E9BDC, stop: 1 #FFFFFF);
}
"""

path_hash_dict = {}
separation_n = 0


def create_separation(path_to_file, api_token, sep_type, add_opt1, add_opt2, add_opt3):
    files = {
        'audiofile': open(path_to_file, 'rb'),
        'api_token': (None, api_token),
        'sep_type': (None, sep_type),
        'add_opt1': (None, add_opt1),
        'add_opt2': (None, add_opt2),
        'add_opt3': (None, add_opt3),
        'output_format': (None, '1'),
        'is_demo': (None, '0'),
    }
    print("files")
    print(files)

    response = requests.post('https://mvsep.com/api/separation/create', files=files)
    if response.status_code == 200:
        response_content = response.content

        # Convert byte array to string
        string_response = response_content.decode('utf-8')

        # Parse string to JSON
        parsed_json = json.loads(string_response)

        # Output result
        hash = parsed_json["data"]["hash"]

        return hash, response.status_code
    else:
        return response.content, response.status_code


def get_separation_types():
    # URL for the request
    api_url = 'https://mvsep.com/api/app/algorithms'

    # Making a GET request
    response = requests.get(api_url)

    # Checking the response status code
    if response.status_code == 200:
        # Parsing the response to JSON
        data = response.json()
        result = {}  # Creating a new dictionary to store data by render_id
        algorithm_fields_result = {}

        # Data structure check (for debugging)
        if isinstance(data, list):  # Checking that data is a list
            for algorithm in data:
                if isinstance(algorithm, dict):  # Checking that each element is a dictionary
                    render_id = algorithm.get('render_id', 'N/A')
                    name = algorithm.get('name', 'N/A')
                    algorithm_group_id = algorithm.get('algorithm_group_id', 'N/A')
                    # print(f"{render_id}: {name}, Group ID: {algorithm_group_id}")

                    # Additional fields
                    algorithm_fields = algorithm.get('algorithm_fields', [])
                    for field in algorithm_fields:
                        if isinstance(field, dict):
                            field_name = field.get('name', 'N/A')
                            field_text = field.get('text', 'N/A')
                            field_options = field.get('options', 'N/A')
                            # Printing additional fields (can be removed if not needed)
                            # print(f"\tField Name: {field_name}, Field Text: {field_text}, Options: {field_options}")

                    # Algorithm descriptions
                    algorithm_descriptions = algorithm.get('algorithm_descriptions', [])
                    for description in algorithm_descriptions:
                        if isinstance(description, dict):
                            short_desc = description.get('short_description', 'N/A')
                            lang = description.get('lang', 'N/A')
                            # Printing algorithm description (can be removed if not needed)
                            # print(f"\tShort Description: {short_desc}, Language: {lang}")

                    # Saving data to result by render_id
                    result[render_id] = name
                    # Printing data for example
                    # print(f"{render_id}: {name}, Group ID: {algorithm_group_id}")

                    algorithm_fields_result[render_id] = algorithm_fields

        else:
            print(f"Unexpected top-level data format: {data}")

        # Returning the result (can be used for further processing)
        # print(result)
        return result, algorithm_fields_result
    else:
        print(f"Request failed with status code: {response.status_code}")


def download_file(url, filename, save_path):
    """
    Download the file from the specified URL and save it in the specified path.
    """
    print("start download")
    response = requests.get(url)
    print("end download")

    if response.status_code == 200:
        # Ensure the directory exists
        if not os.path.exists(save_path):
            os.makedirs(save_path)

        file_path = os.path.join(save_path, filename)

        # Save the content of the response to the file
        with open(file_path, 'wb') as f:
            f.write(response.content)
        return f"File '{filename}' uploaded successfully!"
    else:
        print(f"There was an error loading the file '{filename}'. Status code: {response.status_code}.")


def get_result(hash, save_path):
    success, data = check_result(hash)
    if success:
        try:
            files = data['data']['files']
        except KeyError:
            print("The separation is not ready yet.")
            return ""
        text = ""
        for file_info in files:
            url = file_info['url'].replace('\\/', '/')  # Correct slashes
            filename = file_info['download']  # File name for saving
            text += f'{download_file(url, filename, save_path)}\n'
        return text
    else:
        print("An error occurred while retrieving file data.")


def check_result(hash):
    params = {'hash': hash}
    response = requests.get('https://mvsep.com/api/separation/get', params=params)
    data = json.loads(response.content.decode('utf-8'))

    return data['success'], data


class SepThread(QThread):

    def __init__(self, api_token=None, data_table=None, base_dir_label=None):
        super(SepThread, self).__init__()
        self.data_table = data_table
        self.api_token = api_token
        self.base_dir_label = base_dir_label

    def run(self):
        # Creating a database connection (file my_database.db will be created)
        # self.connection = sqlite3.connect(os.path.join(BASE_DIR, 'jobs.db'), check_same_thread=False)
        global connection
        self.cursor = connection.cursor()

        while True:

            # checking running processes
            # self.cursor.execute('INSERT INTO Jobs (start_time, update_time, filename, out_dir, hash[5], status[6], separation, option1, option2, option3) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', (int(time.time()), int(time.time()), path, self.output_dir, "", "Added", separation_type, option1, option2, option3))
            self.cursor.execute('SELECT * FROM Jobs ORDER BY id DESC')
            jobs = self.cursor.fetchall()
            for row, job in enumerate(jobs):
                # self.data_table.setHorizontalHeaderLabels(["ID", "Start Time", "FileName", "Out Dir", "Separation Type", "Adv.Opt #1", "Adv.Opt #2", "Adv.Opt #3", "Status", "Update Status"])
                # self.data_table.setHorizontalHeaderLabels(["ID", "FileName", "Separation Type""Status"])
                job_id = int(job[0])
                # self.data_table.setItem(row, 0, QTableWidgetItem(str(job_id)))
                # start_date = datetime.strptime(str(job[1]), '%Y-%m-%d %H:%M')
                start_date = datetime.fromtimestamp(job[1])
                start_date = str(start_date.strftime('%Y-%m-%d %H:%M'))

                file_name = os.path.basename(job[3])
                self.data_table.setItem(row, 0, QTableWidgetItem(file_name))

                out_dir = job[4]
                separation_type = str(job[7])
                self.data_table.setItem(row, 1, QTableWidgetItem(separation_type))  # separation
                """
                self.data_table.setItem(row, 5, QTableWidgetItem(job[8])) #  option1
                self.data_table.setItem(row, 6, QTableWidgetItem(job[9])) #  option2
                self.data_table.setItem(row, 7, QTableWidgetItem(job[10])) #  option 3
                """
                status = str(job[6])
                self.data_table.setItem(row, 2, QTableWidgetItem(status))  # status
                update_time = datetime.fromtimestamp(job[2])
                update_time = str(update_time.strftime('%H:%M:%S'))

                if job[6] == "Added":
                    # Attempting to start separation (e.g., generate hash or error)
                    # self.base_dir_label.setText(f"Token: {self.api_token}")

                    hash_val, status_code = create_separation(job[3], self.api_token, separation_type,
                                                              job[8], job[9], job[10])

                    if status_code == 200:  # Success with hash
                        self.cursor.execute('UPDATE Jobs SET hash = ? WHERE id = ?', (hash_val, job[0]))
                        self.cursor.execute('UPDATE Jobs SET status = ? WHERE id = ?', ("Process", job[0]))
                        self.cursor.execute('UPDATE Jobs SET update_time = ? WHERE id = ?', (int(time.time()), job[0]))

                        self.cursor.execute(
                            'INSERT INTO Log (job_id, update_time, action, comment) VALUES (?, ?, ?, ?)',
                            (job_id, int(time.time()), "Added -> Process", ""))

                    else:
                        self.cursor.execute(
                            'INSERT INTO Log (job_id, update_time, action, comment) VALUES (?, ?, ?, ?)',
                            (job_id, int(time.time()), "Error Start Process", f"response.content: {hash_val}"))
                        print("error start process")
                        print(hash_val)

                # connecting the thread to check separation progress
                if job[6] == "Process":
                    self.cursor.execute('UPDATE Jobs SET update_time = ? WHERE id = ?', (int(time.time()), job[0]))
                    self.cursor.execute('INSERT INTO Log (job_id, update_time, action, comment) VALUES (?, ?, ?, ?)',
                                        (job_id, int(time.time()), "Process", f""))

                    params = {'hash': job[5]}
                    response = requests.get('https://mvsep.com/api/separation/get', params=params)
                    data = json.loads(response.content.decode('utf-8'))

                    if data['success']:
                        self.cursor.execute(
                            'INSERT INTO Log (job_id, update_time, action, comment) VALUES (?, ?, ?, ?)',
                            (job_id, int(time.time()), "Process -> Success", f""))

                        files = []
                        try:
                            files = data['data']['files']
                        except KeyError:
                            pass
                            self.cursor.execute(
                                'INSERT INTO Log (job_id, update_time, action, comment) VALUES (?, ?, ?, ?)',
                                (job_id, int(time.time()), "Process -> No Files", f""))

                        for file_info in files:
                            url = file_info['url'].replace('\\/', '/')  # Correct slashes
                            filename = file_info['download']  # File name for saving
                            # download_file(url, filename, save_path)
                            self.cursor.execute('UPDATE Jobs SET status = ? WHERE id = ?', ("Download", job[0]))
                            self.cursor.execute('UPDATE Jobs SET update_time = ? WHERE id = ?',
                                                (int(time.time()), job[0]))
                            self.cursor.execute(
                                'INSERT INTO Log (job_id, update_time, action, comment) VALUES (?, ?, ?, ?)',
                                (job_id, int(time.time()), "Process -> Download", f"filename: {filename}"))

                            print(f"Start download: {url}")
                            response_dl = requests.get(url)  # Renamed to avoid conflict
                            if response_dl.status_code == 200:
                                # Ensure the directory exists
                                if not os.path.exists(job[4]):
                                    os.makedirs(job[4])
                                file_path = os.path.join(job[4], filename)
                                # Save the content of the response to the file
                                with open(file_path, 'wb') as f:
                                    f.write(response_dl.content)
                                    self.cursor.execute('UPDATE Jobs SET status = ? WHERE id = ?', ("Complete", job[0]))
                                self.cursor.execute(
                                    'INSERT INTO Log (job_id, update_time, action, comment) VALUES (?, ?, ?, ?)',
                                    (job_id, int(time.time()), "Process -> Complete", f"filename: {filename}"))


                    else:
                        self.cursor.execute('UPDATE Jobs SET status = ? WHERE id = ?', ("Error", job[0]))
                        self.cursor.execute(
                            'INSERT INTO Log (job_id, update_time, action, comment) VALUES (?, ?, ?, ?)',
                            (job_id, int(time.time()), "Process -> Error", f""))

            # self.data_table.resizeColumnsToContents()
            connection.commit()
            time.sleep(1)


class DragButton(QPushButton):
    dragged = pyqtSignal()

    def dragEnterEvent(self, e):
        print("dragEnterEvent")
        e.accept()

    def dropEvent(self, event):
        self.selected_files = []
        if event.mimeData().hasUrls():
            for url in event.mimeData().urls():
                file_path = url.toLocalFile()
                self.selected_files.append(file_path)
            event.accept()
            self.dragged.emit()
        else:
            event.ignore()

    def mouseMoveEvent(self, e):
        if e.buttons() == Qt.MouseButton.LeftButton:
            drag = QDrag(self)
            mime = QMimeData()
            drag.setMimeData(mime)
            drag.exec(Qt.DropAction.MoveAction)


class MainWindow(QWidget):
    def __init__(self):
        super().__init__()

        # Creating a database connection (file my_database.db will be created)
        global connection
        self.cursor = connection.cursor()

        # Creating table Jobs
        self.cursor.execute('''
        CREATE TABLE IF NOT EXISTS Jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time INTEGER,
        update_time INTEGER,
        filename TEXT NOT NULL,
        out_dir TEXT NOT NULL,
        hash TEXT NOT NULL,
        status TEXT NOT NULL,
        separation INTEGER,
        option1 TEXT NOT NULL,
        option2 TEXT NOT NULL,
        option3 TEXT NOT NULL
        )
        ''')
        connection.commit()

        # Creating table Log
        self.cursor.execute('''
        CREATE TABLE IF NOT EXISTS Log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_id INTEGER,
        update_time INTEGER,
        action TEXT NOT NULL,
        comment TEXT NOT NULL
        )
        ''')
        connection.commit()

        self.setWindowTitle("MVSep.com API: Create Separation")
        self.setGeometry(50, 50, 400, 400)
        self.setFixedSize(740, 600)
        layout = QGridLayout()

        self.token_filename = os.path.join(BASE_DIR, "api_token.txt")
        self.selected_files = []
        if getattr(sys, 'frozen', False):
            self.output_dir = os.path.join(os.path.dirname(sys.executable), 'output/')
        else:
            self.output_dir = os.path.join(os.path.abspath(os.getcwd()), 'output/')
        if not os.path.exists(self.output_dir):  # Ensure output directory exists at startup
            os.makedirs(self.output_dir)
        self.algorithm_fields = {}

        self.alg_opt1 = {}
        self.alg_opt2 = {}
        self.alg_opt3 = {}

        self.selected_opt1 = "0"  # Defaulting to string "0" if these are option keys
        self.selected_opt2 = "0"
        self.selected_opt3 = "0"

        self.selected_algoritms_list = []

        self.data, self.algorithm_fields = get_separation_types()

        """
  TABLE
        """
        # Create a table
        self.data_table = QTableWidget(self)
        self.data_table.setColumnCount(3)  # Set three columns
        self.data_table.setColumnWidth(0, 185)
        self.data_table.setColumnWidth(1, 100)
        self.data_table.setColumnWidth(2, 50)
        self.data_table.setRowCount(10)
        self.data_table.setHorizontalHeaderLabels(["FileName", "Separation Type", "Status"])
        self.data_table.setMinimumWidth(350)
        self.data_table.setMinimumHeight(350)
        # self.data_table.setAutoScroll(True)
        self.data_table.setVerticalScrollMode(QAbstractItemView.ScrollMode.ScrollPerPixel)

        layout.addWidget(self.data_table, 0, 1, 7, 1,
                         alignment=Qt.AlignmentFlag.AlignTop)  # Span changed to match GUI better

        self.file_list_label = QLabel("Selected Files:")
        self.file_list_label.setStyleSheet(label_style)
        layout.addWidget(self.file_list_label, 7, 1, alignment=Qt.AlignmentFlag.AlignTop)
        # text field for the list of files
        self.file_list_text = QTextEdit(self)
        self.file_list_text.toPlainText()
        layout.addWidget(self.file_list_text, 8, 1, 3, 1, alignment=Qt.AlignmentFlag.AlignTop)

        # Field for API Token
        self.api_label = QLabel("API Token")
        self.api_label.setStyleSheet(label_style)
        self.api_input = QLineEdit()
        self.api_input.setStyleSheet(input_style)
        # looking for a file with a token
        if os.path.isfile(self.token_filename):
            with open(self.token_filename, "r") as f:
                api_token = f.read().strip()
                if len(api_token) == 30:
                    self.api_input.setText(api_token)

        layout.addWidget(self.api_label, 0, 0)
        layout.addWidget(self.api_input, 1, 0)

        # Link for API Token
        self.api_link_label = QLabel("<a href='https://mvsep.com/ru/full_api'>Get Token</a>")
        self.api_link_label.setStyleSheet(label_style)
        self.api_link_label.setOpenExternalLinks(True)
        layout.addWidget(self.api_link_label, 2, 0)

        # Button to launch the master
        self.master_button = QPushButton("Algorithms Master")
        self.master_button.setAcceptDrops(True)
        self.master_button.setStyleSheet(button_style)
        self.master_button.clicked.connect(self.start_master)
        layout.addWidget(self.master_button, 3, 0)

        # Selected audio file
        self.filename_label = QLabel("Audio selected:")
        self.filename_label.setStyleSheet(label_style)
        self.filename_label.setOpenExternalLinks(True)  # This might not be intended for filename_label
        layout.addWidget(self.filename_label, 4, 0)
        # Button to select file
        self.file_button = DragButton("Select File")
        self.file_button.setAcceptDrops(True)
        self.file_button.setStyleSheet(button_style)
        self.file_button.clicked.connect(self.select_file)
        self.file_button.dragged.connect(self.select_drag_file)

        layout.addWidget(self.file_button, 5, 0)

        # Clear selected files
        self.clear_files_button = QPushButton("Clear Files")
        self.clear_files_button.setStyleSheet(button_style)
        self.clear_files_button.clicked.connect(self.clear_files)
        layout.addWidget(self.clear_files_button, 6, 0)

        # Selected directory
        self.output_dir_label = QLabel(f"Output Dir: {self.output_dir}")
        self.output_dir_label.setStyleSheet(label_style)
        layout.addWidget(self.output_dir_label, 7, 0)
        # Button to select results directory
        self.output_dir_button = QPushButton("Select Output Dir")
        self.output_dir_button.setStyleSheet(button_style)
        self.output_dir_button.clicked.connect(self.select_output_dir)
        layout.addWidget(self.output_dir_button, 8, 0)

        # Button to create separation
        self.create_button = QPushButton("Create Separation")
        self.create_button.setStyleSheet(cs_button_style)
        self.create_button.clicked.connect(self.process_separation)
        layout.addWidget(self.create_button, 9, 0)

        # Base Dir
        self.base_dir_label = QLabel(f"Base Dir: {BASE_DIR}")
        self.base_dir_label.setStyleSheet(small_label_style)
        layout.addWidget(self.base_dir_label, 10, 0)

        self.setLayout(layout)
        # self.connection.close()

        # connecting the thread to check separation progress

        self.st = SepThread(api_token=self.api_input.text(), data_table=self.data_table,
                            base_dir_label=self.base_dir_label)
        self.st.start()

    def clear_files(self):
        self.selected_files = []
        self.filename_label.setText(f"No Audio selected:")
        # adding to TextEdit
        self.file_list_text.setText("")

    def select_file(self):
        # Opening dialog to select file(s)
        selected_files_tuple = QFileDialog.getOpenFileNames(self, "Select File", "", "Audio Files (*.mp3 *.wav *.flac *m4a *mp4)")
        if selected_files_tuple and selected_files_tuple[0]:  # Check if files were selected
            self.selected_files = selected_files_tuple[0]
            print(f"Files selected:")
            print(self.selected_files)
            if len(self.selected_files) > 0:
                self.filename_label.setText(f"Audio selected: {os.path.basename(self.selected_files[0])}...")
                # adding to TextEdit
                self.file_list_text.setText("")
                selected_files_text = "\n".join(self.selected_files)
                self.file_list_text.setText(selected_files_text)
                self.create_button.setText("Create Separation")
        else:
            self.selected_files = []  # Ensure it's empty if dialog is cancelled
            self.filename_label.setText("No Audio selected:")
            self.file_list_text.setText("")

    def select_drag_file(self):
        self.selected_files = self.file_button.selected_files
        print(f"Files selected:")
        print(self.selected_files)
        if len(self.selected_files) > 0:
            self.filename_label.setText(f"Audio selected: {os.path.basename(self.selected_files[0])}...")
            # adding to TextEdit
            self.file_list_text.setText("")
            selected_files_text = "\n".join(self.selected_files)
            self.file_list_text.setText(selected_files_text)

            self.create_button.setText("Create Separation")

    def on_selection_change(self, index):  # This method appears unused in the current main window context
        # Getting the selected text
        selected_item = self.type_combo.currentText()  # type_combo is not defined in MainWindow scope

        # Searching for the corresponding key for the selected value
        for key, value in self.data.items():
            if value == selected_item:
                self.selected_key = key
                print(f"Selected key: {self.selected_key} - {selected_item}")

                selected_algorithm = self.algorithm_fields[key]
                print("Options Len:")
                print(len(selected_algorithm))
                print("Options:")
                print(selected_algorithm)

                # clearing all ComboBoxes
                self.option1_combo.clear()  # option1_combo is not defined in MainWindow scope
                self.option2_combo.clear()  # option2_combo is not defined in MainWindow scope
                self.option3_combo.clear()  # option3_combo is not defined in MainWindow scope
                self.option1_label.setText("Additional Option 1")  # option1_label is not defined in MainWindow scope
                self.option2_label.setText("Additional Option 2")  # option2_label is not defined in MainWindow scope
                self.option3_label.setText("Additional Option 3")  # option3_label is not defined in MainWindow scope

                if len(self.algorithm_fields[key]) > 0:
                    self.option1_label.setText(f"Additional Option 1: {selected_algorithm[0]['text']}")
                    self.alg_opt1 = json.loads(selected_algorithm[0]['options'])
                    # Sorting the dictionary by key
                    sorted_data = {k: v for k, v in sorted(self.alg_opt1.items())}
                    value_items = sorted_data.values()  # Renamed to avoid conflict
                    # Adding items to the combobox
                    self.option1_combo.addItems(value_items)

                if len(self.algorithm_fields[key]) > 1:
                    self.option2_label.setText(f"Additional Option 2: {selected_algorithm[1]['text']}")
                    self.alg_opt2 = json.loads(selected_algorithm[1]['options'])
                    # Sorting the dictionary by key
                    sorted_data = {k: v for k, v in sorted(self.alg_opt2.items())}
                    value_items = sorted_data.values()  # Renamed to avoid conflict
                    # Adding items to the combobox
                    self.option2_combo.addItems(value_items)

                if len(self.algorithm_fields[key]) > 2:
                    self.option3_label.setText(f"Additional Option 3: {selected_algorithm[2]['text']}")
                    self.alg_opt3 = json.loads(selected_algorithm[2]['options'])
                    # Sorting the dictionary by key
                    sorted_data = {k: v for k, v in sorted(self.alg_opt3.items())}
                    value_items = sorted_data.values()  # Renamed to avoid conflict
                    # Adding items to the combobox
                    self.option3_combo.addItems(value_items)

                break

    def on_change_option1(self, index):  # This method appears unused
        # Getting the selected text
        selected_item = self.option1_combo.currentText()  # option1_combo is not defined in MainWindow scope
        # Searching for the corresponding key for the selected value
        for key, value in self.alg_opt1.items():
            if value == selected_item:
                self.selected_opt1 = key
                break

    def on_change_option2(self, index):  # This method appears unused
        # Getting the selected text
        selected_item = self.option2_combo.currentText()  # option2_combo is not defined in MainWindow scope
        # Searching for the corresponding key for the selected value
        for key, value in self.alg_opt2.items():
            if value == selected_item:
                self.selected_opt2 = key
                break

    def on_change_option3(self, index):  # This method appears unused
        # Getting the selected text
        selected_item = self.option3_combo.currentText()  # option3_combo is not defined in MainWindow scope
        # Searching for the corresponding key for the selected value
        for key, value in self.alg_opt3.items():
            if value == selected_item:
                self.selected_opt3 = key
                break

    def select_output_dir(self):
        # Opening dialog to select folder
        selected_dir = QFileDialog.getExistingDirectory(self, "Select Folder to Save")
        if selected_dir:  # Check if a directory was selected
            self.output_dir = selected_dir
            self.output_dir_label.setText(f"Output Dir: {self.output_dir}")

    def process_separation(self):
        global path_hash_dict, separation_n, connection

        api_token = self.api_input.text()

        # Clear field styles before validation
        self.clear_styles()
        # Validation
        valid = True
        if len(self.selected_files) == 0:  # If file is not selected
            self.file_button.setStyleSheet(
                "background-color: red; font-size: 18px; padding: 20px; min-width: 300px;")  # Highlighting the button in red
            valid = False
        if not api_token:  # If API token is empty
            self.api_input.setStyleSheet("border: 2px solid red; font-size: 18px; padding: 15px; min-width: 300px;")
            valid = False
        else:
            # save to file
            with open(self.token_filename, "w") as f:
                f.write(api_token)

        if len(self.selected_algoritms_list) == 0:  # If separation type is not selected (via master)
            # This validation logic might need adjustment if a single default algorithm is intended
            # For now, it implies master must be used to select at least one algorithm.
            self.master_button.setStyleSheet(
                f"border: 2px solid red; {button_style}")  # Use button_style for consistency
            valid = False

        # Check: if there are errors, do not continue the process
        if not valid:
            if os.name == 'nt':  # For Windows
                os.system('cls')
            else:  # For Linux/MacOS
                os.system('clear')
            print("Error separation:")
            print(f"API Token provided: {'Yes' if api_token else 'No'}")
            print(f"Files selected: {len(self.selected_files)}")
            print(f"Algorithms selected: {len(self.selected_algoritms_list)}")
            return

        self.st.api_token = self.api_input.text()
        """
        start_time INTEGER,
        update_time INTEGER,
        filename TEXT NOT NULL,
        out_dir TEXT NOT NULL,
        hash TEXT NOT NULL,
        status TEXT NOT NULL,
        separation INTEGER,
        option1 TEXT NOT NULL,
        option2 TEXT NOT NULL,
        option3 TEXT NOT NULL,

        """
        # This 'else' block for when selected_algoritms_list is empty was problematic
        # as separation_type, option1 etc. were not defined.
        # The logic now strictly relies on selected_algoritms_list.
        # If a default/single separation without master was intended, it needs to be explicitly handled.

        if len(self.selected_algoritms_list) > 0:
            for new_item in self.selected_algoritms_list:
                separation_type = new_item["selected_key"]
                option1 = new_item["selected_opt1"]
                option2 = new_item["selected_opt2"]
                option3 = new_item["selected_opt3"]

                for file_path in self.selected_files:  # Renamed 'file' to 'file_path'
                    # Adding a new job
                    self.cursor.execute(
                        'INSERT INTO Jobs (start_time, update_time, filename, out_dir, hash, status, separation, option1, option2, option3) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        (int(time.time()), int(time.time()), file_path, self.output_dir, "", "Added", separation_type,
                         str(option1), str(option2), str(option3)))  # Ensure options are strings
                    connection.commit()

                    self.cursor.execute('SELECT * FROM Jobs ORDER BY id DESC LIMIT 0,1')
                    jobs = self.cursor.fetchall()
                    job_id = -1  # Default value
                    if jobs:
                        job_id = int(jobs[0][0])
                    print(f"job_id: {job_id}")

                    # Logging
                    """
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    job_id INTEGER,
                    update_time INTEGER,
                    action TEXT NOT NULL,
                    comment TEXT NOT NULL

                    """
                    if job_id != -1:
                        self.cursor.execute(
                            'INSERT INTO Log (job_id, update_time, action, comment) VALUES (?, ?, ?, ?)',
                            (job_id, int(time.time()), "Added from Master", ""))
                        connection.commit()

            # self.selected_algoritms_list = [] # Clearing list after processing might be desired depending on workflow

        self.create_button.setText("Create Separation +")

    def stop_separation(self, result_text):
        global separation_n
        # completing separation
        QMessageBox.information(self, "Result", result_text)
        self.create_button.setText(f"Create Separation: [{separation_n}]")

    def clear_styles(self):
        # Reset styles
        self.master_button.setStyleSheet(button_style)
        self.file_button.setStyleSheet(button_style)
        self.api_input.setStyleSheet(input_style)

    def start_separation(self, separation_type, api_token, option1, option2, option3,
                         path):  # This method appears unused
        hash_val, status_code = create_separation(path, api_token, separation_type, option1, option2,
                                                  option3)
        if status_code == 200:
            return {"success": True, "hash": hash_val}  # Success with hash
        else:
            return {"success": False, "error": hash_val}

    """
  MASTER
    """

    def start_master(self):
        # Creating a form to display separation types
        separation_dialog = QDialog(self)
        separation_dialog.setWindowTitle("Separation Types")
        # separation_dialog.setGeometry(50, 50, 400, 400)
        separation_dialog.setFixedSize(740, 600)

        layout = QGridLayout(separation_dialog)

        # Separation type selection field
        self.type_label_master = QLabel("Separation Type")
        self.type_label_master.setStyleSheet(label_style)

        self.data, self.algorithm_fields = get_separation_types()

        # Sorting the dictionary by key
        sorted_data = {k: v for k, v in sorted(self.data.items())}

        # Initializing QComboBox
        self.type_combo_master = QComboBox(separation_dialog)  # Parent should be dialog
        value_items = sorted_data.values()  # Renamed
        # Adding items to the combobox
        self.type_combo_master.addItems(list(value_items))  # Ensure it's a list of strings

        # Setting up handler for selection
        self.type_combo_master.currentIndexChanged.connect(self.on_selection_master_change)

        self.type_combo_master.setStyleSheet(combo_style)
        layout.addWidget(self.type_label_master, 0, 0)
        layout.addWidget(self.type_combo_master, 1, 0)

        # Adding additional options 1, 2, 3
        self.option1_label_master = QLabel("Additional Option 1")
        self.option1_label_master.setStyleSheet(label_style)
        # Initializing QComboBox
        self.option1_combo_master = QComboBox(separation_dialog)  # Parent should be dialog
        self.option1_combo_master.setStyleSheet(combo_style)
        # Setting up handler for selection
        self.option1_combo_master.currentIndexChanged.connect(self.on_change_master_option1)
        layout.addWidget(self.option1_label_master, 2, 0)
        layout.addWidget(self.option1_combo_master, 3, 0)

        # Adding additional options 1, 2, 3
        self.option2_label_master = QLabel("Additional Option 2")
        self.option2_label_master.setStyleSheet(label_style)
        # Initializing QComboBox
        self.option2_combo_master = QComboBox(separation_dialog)  # Parent should be dialog
        self.option2_combo_master.setStyleSheet(combo_style)
        # Setting up handler for selection
        self.option2_combo_master.currentIndexChanged.connect(self.on_change_master_option2)
        layout.addWidget(self.option2_label_master, 4, 0)
        layout.addWidget(self.option2_combo_master, 5, 0)

        # Adding additional options 1, 2, 3
        self.option3_label_master = QLabel("Additional Option 3")
        self.option3_label_master.setStyleSheet(label_style)
        # Initializing QComboBox
        self.option3_combo_master = QComboBox(separation_dialog)  # Parent should be dialog
        self.option3_combo_master.setStyleSheet(combo_style)
        # Setting up handler for selection
        self.option3_combo_master.currentIndexChanged.connect(self.on_change_master_option3)
        layout.addWidget(self.option3_label_master, 6, 0)
        layout.addWidget(self.option3_combo_master, 7, 0)

        # Trigger initial population of options
        if self.type_combo_master.count() > 0:
            self.on_selection_master_change(0)

        # Creating a button to add an algorithm
        add_button = QPushButton("Add Algorithm", separation_dialog)
        add_button.setStyleSheet(button_style)  # Applying style to buttons
        add_button.clicked.connect(self.add_algoritm)
        layout.addWidget(add_button, 8, 0)

        # RIGHT COLUMN
        self.algo_list_label = QLabel("Selected Algorithms:")
        self.algo_list_label.setStyleSheet(label_style)
        layout.addWidget(self.algo_list_label, 0, 1, alignment=Qt.AlignmentFlag.AlignTop)
        # text field for the list of algorithms
        self.algo_list_text = QTextEdit(separation_dialog)  # Parent should be dialog
        self.algo_list_text.setPlainText("")  # Use setPlainText
        self.algo_list_text.setMinimumWidth(350)
        self.algo_list_text.setMinimumHeight(386)
        layout.addWidget(self.algo_list_text, 1, 1, 7, 1, alignment=Qt.AlignmentFlag.AlignTop)  # Adjusted span

        # filling the text field
        self._update_algo_list_text()  # Helper function to update text

        # Creating a button to close the form
        close_button = QPushButton("Select Algorithms", separation_dialog)
        close_button.setStyleSheet(button_style)  # Applying style to buttons
        close_button.clicked.connect(separation_dialog.accept)
        layout.addWidget(close_button, 8, 1)  # Positioned below list

        # Creating a button to clear algorithms
        clear_algo_button = QPushButton("Clear Algorithms", separation_dialog)
        clear_algo_button.setStyleSheet(button_style)  # Applying style to buttons
        clear_algo_button.clicked.connect(self.clear_algo)
        layout.addWidget(clear_algo_button, 9, 0, 1, 2)  # Span across both columns

        # Setting layout in the dialog window
        separation_dialog.setLayout(layout)

        # Displaying the dialog window
        separation_dialog.exec()

    def _update_algo_list_text(self):
        selected_algo_text = ""
        for new_item in self.selected_algoritms_list:
            key = new_item["selected_key"]
            selected_opt1 = str(new_item["selected_opt1"])  # Ensure string for dict key
            selected_opt2 = str(new_item["selected_opt2"])
            selected_opt3 = str(new_item["selected_opt3"])

            alg_name = self.data.get(key, "Unknown Algorithm")
            selected_algo_text += f"{alg_name}"

            current_algorithm_fields = self.algorithm_fields.get(key, [])

            if len(current_algorithm_fields) > 0:
                alg_opt1_data = json.loads(current_algorithm_fields[0].get('options', '{}'))
                opt1_text = alg_opt1_data.get(selected_opt1, f"Opt1Val-{selected_opt1}")
                selected_algo_text += f": {opt1_text}"
            if len(current_algorithm_fields) > 1:
                alg_opt2_data = json.loads(current_algorithm_fields[1].get('options', '{}'))
                opt2_text = alg_opt2_data.get(selected_opt2, f"Opt2Val-{selected_opt2}")
                selected_algo_text += f", {opt2_text}"
            if len(current_algorithm_fields) > 2:
                alg_opt3_data = json.loads(current_algorithm_fields[2].get('options', '{}'))
                opt3_text = alg_opt3_data.get(selected_opt3, f"Opt3Val-{selected_opt3}")
                selected_algo_text += f", {opt3_text}"

            selected_algo_text += f"\n"
        self.algo_list_text.setPlainText(selected_algo_text)

    def clear_algo(self):
        self.selected_algoritms_list = []
        self._update_algo_list_text()

    def add_algoritm(self):
        # Getting the selected text
        selected_item_text = self.type_combo_master.currentText()
        separation_type_key = None  # Initialize
        for key, value in self.data.items():
            if value == selected_item_text:
                separation_type_key = key
                break

        # It's good practice to reset styles from previous errors
        self.type_combo_master.setStyleSheet(combo_style)  # Reset style

        if not separation_type_key:  # If separation type is not selected or not found
            self.type_combo_master.setStyleSheet(f"border: 2px solid red; {combo_style}")
            QMessageBox.warning(self, "Error", "Please select a valid separation type.")
            return

        new_item = {}
        new_item["selected_key"] = separation_type_key
        new_item["selected_opt1"] = self.selected_opt1  # These are set by on_change_master_optionX
        new_item["selected_opt2"] = self.selected_opt2
        new_item["selected_opt3"] = self.selected_opt3
        self.selected_algoritms_list.append(new_item)

        # filling the text field
        self._update_algo_list_text()

    def on_selection_master_change(self, index):
        # Getting the selected text
        selected_item_text = self.type_combo_master.currentText()
        self.selected_key = None  # Reset

        # Searching for the corresponding key for the selected value
        for key, value in self.data.items():
            if value == selected_item_text:
                self.selected_key = key
                break

        if not self.selected_key: return  # Should not happen if combo is populated correctly

        current_algorithm_fields = self.algorithm_fields.get(self.selected_key, [])

        # clearing all ComboBoxes in the master window
        self.option1_combo_master.clear()
        self.option2_combo_master.clear()
        self.option3_combo_master.clear()
        self.option1_label_master.setText("Additional Option 1")
        self.option2_label_master.setText("Additional Option 2")
        self.option3_label_master.setText("Additional Option 3")

        # Reset selected options to defaults (e.g., first item or "0")
        self.selected_opt1 = "0"
        self.selected_opt2 = "0"
        self.selected_opt3 = "0"

        if len(current_algorithm_fields) > 0:
            field1_info = current_algorithm_fields[0]
            self.option1_label_master.setText(f"Option 1: {field1_info.get('text', 'N/A')}")
            self.alg_opt1 = json.loads(field1_info.get('options', '{}'))
            # Sorting the dictionary by key (assuming keys are sortable, e.g., numbers as strings)
            try:  # Handle cases where keys might not be directly sortable as integers
                sorted_data_opt1 = {k: v for k, v in sorted(self.alg_opt1.items(), key=lambda item: int(item[0]))}
            except ValueError:
                sorted_data_opt1 = {k: v for k, v in sorted(self.alg_opt1.items())}

            value_items1 = list(sorted_data_opt1.values())
            # Adding items to the combobox
            self.option1_combo_master.addItems(value_items1)
            if value_items1: self.on_change_master_option1(0)  # Set default

        if len(current_algorithm_fields) > 1:
            field2_info = current_algorithm_fields[1]
            self.option2_label_master.setText(f"Option 2: {field2_info.get('text', 'N/A')}")
            self.alg_opt2 = json.loads(field2_info.get('options', '{}'))
            try:
                sorted_data_opt2 = {k: v for k, v in sorted(self.alg_opt2.items(), key=lambda item: int(item[0]))}
            except ValueError:
                sorted_data_opt2 = {k: v for k, v in sorted(self.alg_opt2.items())}
            value_items2 = list(sorted_data_opt2.values())
            self.option2_combo_master.addItems(value_items2)
            if value_items2: self.on_change_master_option2(0)

        if len(current_algorithm_fields) > 2:
            field3_info = current_algorithm_fields[2]
            self.option3_label_master.setText(f"Option 3: {field3_info.get('text', 'N/A')}")
            self.alg_opt3 = json.loads(field3_info.get('options', '{}'))
            try:
                sorted_data_opt3 = {k: v for k, v in sorted(self.alg_opt3.items(), key=lambda item: int(item[0]))}
            except ValueError:
                sorted_data_opt3 = {k: v for k, v in sorted(self.alg_opt3.items())}
            value_items3 = list(sorted_data_opt3.values())
            self.option3_combo_master.addItems(value_items3)
            if value_items3: self.on_change_master_option3(0)

    def on_change_master_option1(self, index):
        # Getting the selected text
        selected_item_text = self.option1_combo_master.currentText()
        # Searching for the corresponding key for the selected value
        for key, value in self.alg_opt1.items():
            if value == selected_item_text:
                self.selected_opt1 = key
                break

    def on_change_master_option2(self, index):
        # Getting the selected text
        selected_item_text = self.option2_combo_master.currentText()
        # Searching for the corresponding key for the selected value
        for key, value in self.alg_opt2.items():
            if value == selected_item_text:
                self.selected_opt2 = key
                break

    def on_change_master_option3(self, index):
        # Getting the selected text
        selected_item_text = self.option3_combo_master.currentText()
        # Searching for the corresponding key for the selected value
        for key, value in self.alg_opt3.items():
            if value == selected_item_text:
                self.selected_opt3 = key
                break


if __name__ == "__main__":
    app = QApplication(sys.argv)
    main_window = MainWindow()
    icon_path = os.path.join(BASE_DIR, 'mvsep.ico')
    main_window.setWindowIcon(QIcon(icon_path))
    app.setWindowIcon(QIcon(icon_path))
    main_window.show()
    sys.exit(app.exec())
````

## File: python_example5_gui/README.md
````markdown
# Project: GUI for Interaction with MVSep.com Website

This document serves as a user guide for utilizing the graphical user interface (GUI) specifically designed for interacting with the MVSep.com website. The interface allows users to upload files, choose processing algorithms, and track operation statuses. We will explore the project structure, its core components, and steps for configuration and launching the application.

## Overview of Application

The application is built using the PyQt6 framework, which is widely used for developing desktop applications with graphical interfaces. Its primary goal is to simplify the process of uploading audio files and configuring various sound-processing algorithms. This significantly enhances user interaction with MVSep.com by enabling efficient handling of large datasets and faster results delivery.

### Interface 

<kbd>![Interface for MVSep GUI](images/GUI-Interface.png)</kbd>

## Key Features

1. **File Upload:**
   Users can select one or multiple audio files for further processing. Supported formats include MP3 and WAV. Users have the ability to directly drag and drop files into the application window or use their operating system's standard file selection dialog.

2. **Algorithm Selection:**
   A convenient wizard provides options for selecting different sound signal processing algorithms. Available choices include instrument separation, noise reduction, and quality enhancement. Each algorithm comes with advanced settings that allow customization tailored to specific needs.

3. **Multi-algorithm Processing:**
   The interface supports simultaneous processing of a single file through multiple algorithms, ensuring flexibility and ease when working with diverse scenarios involving sound signal processing.

4. **Process Monitoring:**
   Operation statuses are displayed in real-time via a dedicated table. Users can monitor each stage of every file being processed, starting from initial loading up until final completion.

5. **Thread Utilization (QThread):**
   The application leverages multithreading, providing smooth performance even during heavy processing tasks. Each thread tracks individual task progress, updating state information within the status table dynamically.

## Installation and Launch

To launch the application, simply execute the executable file `MVSepApp.exe`. This eliminates the need for installing all required dependencies onto the user's device.

## Application Architecture

The project consists of several essential components:

- **MainWindow:** The main application window implemented by the `MainWindow` class.
- **SepThread:** A thread class responsible for monitoring process states.
- **DragButton:** Button supporting drag-and-drop functionality for file transfers.
- **Database:** An SQLite database storing operational history and current assignments.

### Class MainWindow
The core component of the application contains widgets such as tables, buttons for file selection, and algorithm setup. It implements logic for managing program state and visualizing user actions.

### Class SepThread
A subclass of `QThread` designed for tracking and updating process statuses. It polls servers periodically and updates both the database and user interface accordingly.

### Basic Logic of the Application
Upon startup, the application establishes a connection to an SQLite database where tasks and log entries are stored. When a user selects a file and clicks “Create Separation,” a record is created in the database, initiating the file processing workflow.

## Implementation Highlights

### Use of Threads
One significant feature of this application is its utilization of threads (`QThread`) for parallel file processing. This ensures seamless operation even under extended processing operations.

Each thread regularly queries server-side task statuses and updates corresponding rows in the status table, allowing users to view real-time progress across all active processes.

## Data Storage
All completed operations are recorded in a local SQLite database. This storage retains critical details including:

- Unique task identifier.
- Name of the processed file.
- Selected processing type.
- Current task status.
- Additional metadata related to status changes.

This architecture helps users manage ongoing tasks efficiently and review past activities easily.

## Graphical User Interface
The GUI is developed using the PyQt6 libraries. Elements of the user interface include:

- Input field for entering a user token (with a link provided below it for authenticated users who haven't obtained a token yet).
- Table displaying the current status of tasks.
- Buttons for file selection and initiation of processing.
- Wizard for choosing algorithms and setting them up.
- Directory selector button specifying output directories for saved separations.
- Display of already-selected files and algorithms to enhance usability.
- Clearing options for removing previously chosen files or algorithms when needed.
````

## File: README.md
````markdown
# MVSep API Examples

Repository with examples of API usage for site [https://mvsep.com](https://mvsep.com). Full API documentation is available [here](https://mvsep.com/en/full_api). 

## Python examples

### Example 1

[api_example.py](python_example1/api_example.py) - console example with 3 different methods: 
* `get_types` - get list of all possible types of separation
* `create_separation` - create separation task with given parameters
* `get_result` - get result of separation. It's called manually.

[Detailed description →](python_example1/README.md)

### Example 2

In this example you provide path to folder, which contains audio-files. Script process each file one by one and automatically download all separated files when they're ready. It can be slow for free MVSep account.

[api_example2.py](python_example2/api_example2.py) - console example with 2 different methods: 
* `get_types` - get list of all possible types of separation
* `separate` - create separation task with given parameters

[Detailed description →](python_example2/README.md)

### Example 3

This example uses `MVSEPClient` class to create separations. It also automatically separate many files at once and download them after finish. Initial version proposed by [@jarredou](https://github.com/jarredou).

[mvsep_client.py](python_example3/mvsep_client.py)
* `get_types` - get list of all possible types of separation
* `separate` - create separation task with given parameters

[Detailed description →](python_example3/README.md)

### Example 4

Simple GUI for creating separation using MVSep API. You can run it with 2 methods:
1) `python3 mvsep_client_gui.py`
2) `mvsep_client_gui_win.exe` - binary file for Windows 10/11 you can run directly without python installed.

#### Interface

<kbd>![Interface for MVSep GUI](python_example4_gui/images/GUI-Interface.png)</kbd>

[Detailed description →](python_example4_gui/README.md)

### Example 5

Complex GUI for creating separation using MVSep API. It allows to add multiple files for separation as well as multiple algorithms. You can run it with 2 methods:
1) `python3 mvsep_client_gui.py`
2) `mvsep_client_gui_win.exe` - binary file for Windows 10/11 you can run directly without python installed.

#### Interface

<kbd>![Interface for MVSep GUI](python_example5_gui/images/GUI-Interface.png)</kbd>

[Detailed description →](python_example5_gui/README.md)
````
