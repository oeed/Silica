
class "BackSymbol" extends "Symbol" {

    symbolName =  "back";

    width = 4;

    serialisedPaths = {
        {
            x = 1,
            y = 1,
            lines = {
                {
                    y1 = 1,
                    x1 = 1,
                    x2 = 4,
                    mode = "linear",
                    y2 = 4,
                },
                {
                    y1 = 4,
                    x1 = 4,
                    x2 = 1,
                    mode = "linear",
                    y2 = 7,
                },
                {
                    y1 = 7,
                    x1 = 1,
                    x2 = 1,
                    mode = "linear",
                    y2 = 1,
                },
            },
            height = 7,
            width = 4,
        }
    }


}
