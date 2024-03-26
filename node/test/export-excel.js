const XLSX = require("xlsx");

(async () => {
    const originWorkbook = XLSX.readFile('demo.xlsx');

    /* get first worksheet */
    const sheetName = originWorkbook.SheetNames[0];
    const worksheet = originWorkbook.Sheets[sheetName];

    /* generate worksheet and workbook */
    const newWorkbook = XLSX.utils.book_new();

    XLSX.utils.book_append_sheet(newWorkbook, worksheet, sheetName);

    /* fix headers */
    // XLSX.utils.sheet_add_aoa(worksheet, [["Name", "Birthday"]], { origin: "A1" });

    /* calculate column width */
    // const max_width = rows.reduce((w, r) => Math.max(w, r.name.length), 10);
    // worksheet["!cols"] = [{ wch: max_width }];

    /* create an XLSX file and try to save to Presidents.xlsx */
    XLSX.writeFile(newWorkbook, "demo-resave1.xlsx", { compression: false });
    XLSX.writeFile(newWorkbook, "demo-resave2.xlsx", { compression: true });
})();