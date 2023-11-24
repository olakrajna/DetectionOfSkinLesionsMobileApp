using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace UploadAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProfileController : ControllerBase
    {

        [HttpGet("health")]
        public ActionResult<string> Health(){
            return Ok("Backend is working");
        }

        [HttpPost("upload-mutiple")]
        [Produces("application/json")]
        [DisableRequestSizeLimit]
        public ActionResult<string> UploadMultiple(
            [FromForm(Name = "files")] List<IFormFile> files
        ) {
            if(files.Count == 0) return BadRequest();
            List<string> data = new List<string>();
            foreach(var file in files) {
                data.Add($"Filename: {file.FileName} || Type: {file.ContentType}");
            }

            return Ok(new {
                message =  $"Uploaded {files.Count} files",
                files = data
            });
        }

    }
}