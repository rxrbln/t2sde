#include <string>
#include <fstream>
#include <sstream>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

class CurlException {};
class TimeoutException : public CurlException {};
class UnsupportedProtocollException : public CurlException {};
class MalformedUrlException : public CurlException {};
class ConnectErrorException : public CurlException {};

class CurlWrapper
{
public:
  CurlWrapper () {
    SetConnectTimeout(20);
    SetMaxTime(-1);
    char* templ=strdup("/tmp/curl_downloadXXXXXX");
    filename = mktemp(templ);
    free(templ);
  }

  void SetConnectTimeout (int value) {connect_timeout = value;}
  void SetMaxTime (int value) {max_time = value;}

  void Download (std::string url) {
    GenParamString ();
    params << " " << url;
    std::cout << params.str () << std::endl;
  }

  void Download (std::string url, unsigned int start, unsigned int end);

  void SetFile (std::string name) {filename=name;}

  std::ifstream* OpenFile () {
    std::ifstream* r=new std::ifstream();
    r -> open(filename.c_str());
    return r;
  }

  void RemoveFile () {unlink (filename.c_str());}

private:

  void GenParamString () {
    params.clear();
    params << "curl -o " << filename;
    if (connect_timeout > 0)
      params << " --conect-timeout " << connect_timeout;
    if (max_time > 0)
      params << " --max-time " << max_time;
  }

  int connect_timeout;
  int max_time;
  std::string filename;

  std::stringstream params;
};
