from flask import Flask, render_template, request
import pyodbc
import json
from datetime import timedelta, date

app = Flask(__name__)

# Database connection details
def get_db_connection():
    connection = pyodbc.connect(
        'DRIVER={ODBC Driver 17 for SQL Server};'
        'SERVER=DESKTOP-GAA9DE5;'
        'DATABASE=GameStore;'
        'Trusted_Connection=yes;'
    )
    return connection

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/sales_by_category', methods=['GET', 'POST'])
def sales_by_category():
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("EXEC GetSalesByCategory")
    data = cursor.fetchall()
    connection.close()

    categories = {row[0] for row in data}
    selected_category = request.form.get('category') if request.method == 'POST' else None
    filtered_data = [row for row in data if row[0] == selected_category] if selected_category else data

    return render_template('sales_by_category.html', categories=categories, data=filtered_data, selected_category=selected_category)

@app.route('/game_sales_review', methods=['GET', 'POST'])
def game_sales_review():
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("EXEC GetGameSalesAndReviewAnalysis")
    data = cursor.fetchall()
    connection.close()

    categories = {row[2] for row in data}
    selected_category = request.form.get('category') if request.method == 'POST' else None
    sort_key = request.form.get('sort_key') if request.method == 'POST' else None

    if selected_category:
        data = [row for row in data if row[2] == selected_category]

    if sort_key:
        key_index = {'Total Sales': 3, 'Total Revenue': 4, 'Rating': 5}.get(sort_key)
        data.sort(key=lambda x: x[key_index], reverse=True)

    return render_template('game_sales_review.html', categories=categories, data=data, selected_category=selected_category, sort_key=sort_key)

@app.route('/revenue_by_category', methods=['GET', 'POST'])
def revenue_by_category():
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT DISTINCT CategoryName FROM Categories")
    categories = [row[0] for row in cursor.fetchall()]
    
    selected_category = request.form.get('category', categories[0])

    cursor.execute("EXEC GetRevenueByCategoryLast6Months")
    data = cursor.fetchall()
    filtered_data = [row for row in data if row[0] == selected_category]

    today = date.today()
    dates = [(today - timedelta(days=i)).isoformat() for i in range(0, 180)]  

    chart_data = {date_str: 0 for date_str in dates}  
    for row in filtered_data:
        date_str = row[1].isoformat()  
        revenue = row[2]
        if date_str in chart_data:
            chart_data[date_str] += revenue 

    chart_labels = list(chart_data.keys())
    chart_values = [float(value) for value in chart_data.values()]  

    chart_labels.reverse()
    chart_values.reverse()

    connection.close()

    return render_template(
        'revenue_by_category.html',
        categories=categories,
        data=filtered_data,
        selected_category=selected_category,
        chart_labels=json.dumps(chart_labels),
        chart_values=json.dumps(chart_values)
    )




@app.route('/wishlist_additions', methods=['GET', 'POST'])
def wishlist_additions():
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("EXEC GetWishlistAdditionsAndGameDetails")
    data = cursor.fetchall()
    connection.close()

    categories = {row[3] for row in data}
    selected_category = request.form.get('category') if request.method == 'POST' else None
    sort_key = request.form.get('sort_key') if request.method == 'POST' else None

    if selected_category:
        data = [row for row in data if row[3] == selected_category]

    if sort_key:
        key_index = {'Wishlist Additions': 4, 'Rating': 5}.get(sort_key)
        data.sort(key=lambda x: x[key_index], reverse=True)

    return render_template('wishlist_additions.html', categories=categories, data=data, selected_category=selected_category, sort_key=sort_key)

@app.route('/customer_patterns', methods=['GET', 'POST'])
def customer_patterns():
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("EXEC GetCustomerPurchaseAndReviewPatterns")
    data = cursor.fetchall()
    connection.close()

    sort_key = request.form.get('sort_key') if request.method == 'POST' else None

    if sort_key:
        key_index = {'Total Orders': 3, 'Total Spending': 4, 'Average Order Value': 5}.get(sort_key)
        data.sort(key=lambda x: x[key_index], reverse=True)

    return render_template('customer_patterns.html', data=data, sort_key=sort_key)

if __name__ == '__main__':
    app.run(debug=True)
