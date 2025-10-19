from fastapi import FastAPI, Request, Form
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles

# Import functions from data_handler
from app.data_handler import save_form_data, get_all_submissions

app = FastAPI()

# Configure templates directory
templates = Jinja2Templates(directory="app/templates")

@app.get("/", response_class=HTMLResponse)
async def get_form(request: Request):
    return templates.TemplateResponse("form.html", {"request": request})

@app.get("/submissions", response_class=HTMLResponse)
async def view_submissions(request: Request):
    # Get all submissions using data_handler function
    submissions = get_all_submissions()
    return templates.TemplateResponse("submissions.html", {
        "request": request,
        "submissions": submissions
    })

@app.post("/submit", response_class=HTMLResponse)
async def submit_form(
    request: Request,
    name: str = Form(...),
    email: str = Form(...),
    phone: str = Form(...),
    location: str = Form(...)
):
    # Save form data using data_handler function
    save_form_data(name, email, phone, location)
    
    # Return success page
    return templates.TemplateResponse("success.html", {
        "request": request,
        "name": name
    })

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=True)
